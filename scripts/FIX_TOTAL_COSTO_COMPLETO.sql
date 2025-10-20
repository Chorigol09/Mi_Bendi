USE DBVENTAS_WEB
GO

-- =============================================
-- CORRECCIÓN COMPLETA DEL TOTAL COSTO EN COMPRAS
-- =============================================

PRINT '╔════════════════════════════════════════════════╗'
PRINT '║   CORRECCIÓN COMPLETA DE TOTAL COSTO COMPRAS   ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''

-- =============================================
-- PARTE 1: Corregir SP de REGISTRO
-- =============================================
PRINT '1. Corrigiendo usp_RegistrarCompra...'
PRINT '   - Calculando TotalCosto desde detalles en lugar de XML'
GO

CREATE OR ALTER PROCEDURE usp_RegistrarCompra
@Detalle XML
AS
BEGIN
    BEGIN TRY
        DECLARE @IdCompra INT = 0
        DECLARE @IdUsuario INT = 0
        DECLARE @IdProveedor INT = 0
        DECLARE @IdTienda INT = 0
        DECLARE @TotalCosto DECIMAL(18,2) = 0

        -- Extraer datos del XML
        DECLARE @datos TABLE(
            IdProducto INT,
            Cantidad INT,
            PrecioUnidadCompra DECIMAL(18,2),
            PrecioUnidadVenta DECIMAL(18,2),
            TotalCosto DECIMAL(18,2)
        )

        INSERT INTO @datos
        SELECT 
            T.Item.value('IdProducto[1]', 'INT'),
            T.Item.value('Cantidad[1]', 'INT'),
            T.Item.value('PrecioUnidadCompra[1]', 'DECIMAL(18,2)'),
            T.Item.value('PrecioUnidadVenta[1]', 'DECIMAL(18,2)'),
            T.Item.value('TotalCosto[1]', 'DECIMAL(18,2)')
        FROM @Detalle.nodes('DETALLE/DETALLE_COMPRA/DETALLE') AS T(Item)

        SELECT 
            @IdUsuario = T.Item.value('IdUsuario[1]', 'INT'),
            @IdProveedor = T.Item.value('IdProveedor[1]', 'INT'),
            @IdTienda = T.Item.value('IdTienda[1]', 'INT')
        FROM @Detalle.nodes('DETALLE/COMPRA') AS T(Item)

        -- ✅ CALCULAR el TotalCosto desde los detalles, NO desde el XML
        SELECT @TotalCosto = SUM(TotalCosto) FROM @datos

        BEGIN TRANSACTION REGISTRAR

        -- Insertar Orden de Compra con el total calculado
        INSERT INTO ORDEN_COMPRA(IdUsuario, IdProveedor, IdTienda, TotalCosto, Estado)
        VALUES(@IdUsuario, @IdProveedor, @IdTienda, @TotalCosto, 'Abierta')

        SET @IdCompra = SCOPE_IDENTITY()

        -- Insertar Detalle
        INSERT INTO DETALLE_ORDEN_COMPRA(IdOrdenCompra, IdProducto, Cantidad, PrecioUnitarioCompra, PrecioUnitarioVenta, TotalCosto)
        SELECT @IdCompra, IdProducto, Cantidad, PrecioUnidadCompra, PrecioUnidadVenta, TotalCosto FROM @datos

        COMMIT TRANSACTION REGISTRAR

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION REGISTRAR
    END CATCH
END
GO

PRINT '   ✓ usp_RegistrarCompra corregido'
PRINT ''

-- =============================================
-- PARTE 2: Corregir SP de CONSULTA
-- =============================================
PRINT '2. Corrigiendo usp_ObtenerListaCompra...'
PRINT '   - Calculando TotalCosto desde DETALLE_ORDEN_COMPRA'
GO

CREATE OR ALTER PROCEDURE usp_ObtenerListaCompra
    @FechaInicio DATE,
    @FechaFin DATE,
    @IdProveedor INT,
    @IdTienda INT
AS
BEGIN
    SELECT 
        oc.IdCompra,
        CONVERT(VARCHAR(10), oc.FechaRegistro, 103) AS NumeroCompra,
        p.RazonSocial,
        t.Nombre,
        CONVERT(VARCHAR(10), oc.FechaRegistro, 103) AS FechaCompra,
        -- ✅ CALCULAR el total desde los detalles
        ISNULL(detalle.TotalCostoCalculado, 0) AS TotalCosto,
        ISNULL(oc.Estado, 'Abierta') AS Estado,
        ISNULL(detalle.CantidadProductos, 0) AS CantidadProductos,
        ISNULL(productos.Productos, '') AS Productos
    FROM ORDEN_COMPRA oc
    INNER JOIN PROVEEDOR p ON oc.IdProveedor = p.IdProveedor
    INNER JOIN TIENDA t ON oc.IdTienda = t.IdTienda
    -- Calcular cantidad y total desde detalles
    OUTER APPLY (
        SELECT 
            SUM(doc.Cantidad) AS CantidadProductos,
            SUM(doc.TotalCosto) AS TotalCostoCalculado
        FROM DETALLE_ORDEN_COMPRA doc
        WHERE doc.IdOrdenCompra = oc.IdCompra
    ) detalle
    -- Lista de productos
    OUTER APPLY (
        SELECT STUFF((
            SELECT ', ' + pr.Nombre + ' (' + CAST(doc2.Cantidad AS VARCHAR(10)) + ')'
            FROM DETALLE_ORDEN_COMPRA doc2
            INNER JOIN PRODUCTO pr ON doc2.IdProducto = pr.IdProducto
            WHERE doc2.IdOrdenCompra = oc.IdCompra
            FOR XML PATH('')
        ), 1, 2, '') AS Productos
    ) productos
    WHERE 
        CONVERT(DATE, oc.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
        AND (@IdProveedor = 0 OR oc.IdProveedor = @IdProveedor)
        AND (@IdTienda = 0 OR oc.IdTienda = @IdTienda)
    ORDER BY oc.FechaRegistro DESC
END
GO

PRINT '   ✓ usp_ObtenerListaCompra corregido'
PRINT ''

-- =============================================
-- PARTE 3: Actualizar registros existentes
-- =============================================
PRINT '3. Actualizando registros existentes...'
PRINT '   - Recalculando TotalCosto en ORDEN_COMPRA'
GO

UPDATE oc
SET oc.TotalCosto = detalle.TotalCalculado
FROM ORDEN_COMPRA oc
INNER JOIN (
    SELECT 
        IdOrdenCompra,
        SUM(TotalCosto) AS TotalCalculado
    FROM DETALLE_ORDEN_COMPRA
    GROUP BY IdOrdenCompra
) detalle ON oc.IdCompra = detalle.IdOrdenCompra
WHERE ABS(oc.TotalCosto - detalle.TotalCalculado) > 0.01
GO

DECLARE @RegistrosActualizados INT
SET @RegistrosActualizados = @@ROWCOUNT

PRINT '   ✓ Registros actualizados: ' + CAST(@RegistrosActualizados AS VARCHAR(10))
PRINT ''

-- =============================================
-- VERIFICACIÓN
-- =============================================
PRINT '4. Verificando correcciones...'
PRINT ''

-- Verificar que no haya diferencias
SELECT 
    oc.IdCompra,
    oc.TotalCosto AS [Total_en_Tabla],
    ISNULL(SUM(doc.TotalCosto), 0) AS [Total_Calculado],
    CASE 
        WHEN ABS(oc.TotalCosto - ISNULL(SUM(doc.TotalCosto), 0)) < 0.01 THEN '✓ OK'
        ELSE '✗ DIFERENCIA: ' + CAST(ABS(oc.TotalCosto - ISNULL(SUM(doc.TotalCosto), 0)) AS VARCHAR(20))
    END AS Estado
FROM ORDEN_COMPRA oc
LEFT JOIN DETALLE_ORDEN_COMPRA doc ON oc.IdCompra = doc.IdOrdenCompra
GROUP BY oc.IdCompra, oc.TotalCosto
ORDER BY oc.IdCompra DESC

PRINT ''
PRINT '╔════════════════════════════════════════════════╗'
PRINT '║           ✅ CORRECCIÓN COMPLETADA             ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''
PRINT 'CAMBIOS REALIZADOS:'
PRINT '  ✓ usp_RegistrarCompra: Calcula total desde detalles'
PRINT '  ✓ usp_ObtenerListaCompra: Muestra total calculado'
PRINT '  ✓ Registros existentes: Actualizados correctamente'
PRINT ''
PRINT 'PRÓXIMOS PASOS:'
PRINT '  1. Crear una nueva orden de compra de prueba'
PRINT '  2. Verificar que el total se registre correctamente'
PRINT '  3. Ir a Consultar Ordenes y verificar totales'
PRINT ''
GO
