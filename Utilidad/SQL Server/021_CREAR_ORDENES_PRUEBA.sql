USE DBVENTAS_WEB
GO

-- =============================================
-- Script: Crear Órdenes de Compra de Prueba
-- Descripción: Genera múltiples órdenes de compra aleatorias para testing
-- =============================================

PRINT '╔════════════════════════════════════════════════╗'
PRINT '║  CREAR ÓRDENES DE COMPRA DE PRUEBA            ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''

-- Verificar que existen datos necesarios
DECLARE @CantProveedores INT
DECLARE @CantTiendas INT
DECLARE @CantProductos INT
DECLARE @CantUsuarios INT

SELECT @CantProveedores = COUNT(*) FROM PROVEEDOR WHERE Activo = 1
SELECT @CantTiendas = COUNT(*) FROM TIENDA WHERE Activo = 1
SELECT @CantProductos = COUNT(*) FROM PRODUCTO WHERE Activo = 1
SELECT @CantUsuarios = COUNT(*) FROM USUARIO WHERE Activo = 1

PRINT 'Verificando datos existentes...'
PRINT '  Proveedores activos: ' + CAST(@CantProveedores AS VARCHAR(10))
PRINT '  Tiendas activas: ' + CAST(@CantTiendas AS VARCHAR(10))
PRINT '  Productos activos: ' + CAST(@CantProductos AS VARCHAR(10))
PRINT '  Usuarios activos: ' + CAST(@CantUsuarios AS VARCHAR(10))
PRINT ''

IF @CantProveedores = 0 OR @CantTiendas = 0 OR @CantProductos = 0 OR @CantUsuarios = 0
BEGIN
    PRINT '❌ ERROR: No hay suficientes datos para crear órdenes de compra'
    PRINT '   Necesitas al menos 1 proveedor, 1 tienda, 1 producto y 1 usuario'
    RETURN
END

PRINT 'Creando 20 órdenes de compra de prueba...'
PRINT ''

-- Variables para el loop
DECLARE @i INT = 1
DECLARE @IdUsuario INT
DECLARE @IdProveedor INT
DECLARE @IdTienda INT
DECLARE @IdProducto1 INT
DECLARE @IdProducto2 INT
DECLARE @IdProducto3 INT
DECLARE @Cantidad1 INT
DECLARE @Cantidad2 INT
DECLARE @Cantidad3 INT
DECLARE @Precio1 DECIMAL(18,2)
DECLARE @Precio2 DECIMAL(18,2)
DECLARE @Precio3 DECIMAL(18,2)
DECLARE @TotalCosto DECIMAL(18,2)
DECLARE @FechaBase DATE
DECLARE @IdCompra INT

-- Obtener primer usuario activo
SELECT TOP 1 @IdUsuario = IdUsuario FROM USUARIO WHERE Activo = 1

-- Crear 20 órdenes de compra
WHILE @i <= 20
BEGIN
    -- Seleccionar proveedor y tienda aleatorios
    SELECT TOP 1 @IdProveedor = IdProveedor 
    FROM PROVEEDOR 
    WHERE Activo = 1 
    ORDER BY NEWID()
    
    SELECT TOP 1 @IdTienda = IdTienda 
    FROM TIENDA 
    WHERE Activo = 1 
    ORDER BY NEWID()
    
    -- Seleccionar 3 productos aleatorios
    SELECT TOP 1 @IdProducto1 = IdProducto 
    FROM PRODUCTO 
    WHERE Activo = 1 
    ORDER BY NEWID()
    
    SELECT TOP 1 @IdProducto2 = IdProducto 
    FROM PRODUCTO 
    WHERE Activo = 1 AND IdProducto != @IdProducto1
    ORDER BY NEWID()
    
    SELECT TOP 1 @IdProducto3 = IdProducto 
    FROM PRODUCTO 
    WHERE Activo = 1 AND IdProducto NOT IN (@IdProducto1, @IdProducto2)
    ORDER BY NEWID()
    
    -- Generar cantidades aleatorias (entre 5 y 50)
    SET @Cantidad1 = 5 + (ABS(CHECKSUM(NEWID())) % 46)
    SET @Cantidad2 = 5 + (ABS(CHECKSUM(NEWID())) % 46)
    SET @Cantidad3 = 5 + (ABS(CHECKSUM(NEWID())) % 46)
    
    -- Generar precios aleatorios (entre $500 y $5000)
    SET @Precio1 = 500 + (ABS(CHECKSUM(NEWID())) % 4500) + (ABS(CHECKSUM(NEWID())) % 100) * 0.01
    SET @Precio2 = 500 + (ABS(CHECKSUM(NEWID())) % 4500) + (ABS(CHECKSUM(NEWID())) % 100) * 0.01
    SET @Precio3 = 500 + (ABS(CHECKSUM(NEWID())) % 4500) + (ABS(CHECKSUM(NEWID())) % 100) * 0.01
    
    -- Calcular total
    SET @TotalCosto = (@Cantidad1 * @Precio1) + (@Cantidad2 * @Precio2) + (@Cantidad3 * @Precio3)
    
    -- Fecha aleatoria en los últimos 30 días
    SET @FechaBase = DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 30), GETDATE())
    
    -- Insertar Orden de Compra
    INSERT INTO ORDEN_COMPRA (IdUsuario, IdProveedor, IdTienda, TotalCosto, Estado, Activo, FechaRegistro)
    VALUES (@IdUsuario, @IdProveedor, @IdTienda, @TotalCosto, 'Abierta', 1, @FechaBase)
    
    SET @IdCompra = SCOPE_IDENTITY()
    
    -- Insertar Detalles
    INSERT INTO DETALLE_ORDEN_COMPRA (IdOrdenCompra, IdProducto, Cantidad, PrecioUnitarioCompra, PrecioUnitarioVenta, TotalCosto, Activo, FechaRegistro)
    VALUES 
        (@IdCompra, @IdProducto1, @Cantidad1, @Precio1, @Precio1 * 1.3, @Cantidad1 * @Precio1, 1, @FechaBase),
        (@IdCompra, @IdProducto2, @Cantidad2, @Precio2, @Precio2 * 1.3, @Cantidad2 * @Precio2, 1, @FechaBase),
        (@IdCompra, @IdProducto3, @Cantidad3, @Precio3, @Precio3 * 1.3, @Cantidad3 * @Precio3, 1, @FechaBase)
    
    IF @i % 5 = 0
        PRINT '  ✓ Creadas ' + CAST(@i AS VARCHAR(10)) + ' órdenes...'
    
    SET @i = @i + 1
END

PRINT ''
PRINT '✓ 20 órdenes de compra creadas exitosamente'
PRINT ''

-- Mostrar resumen
PRINT 'Resumen de órdenes creadas:'
SELECT TOP 20
    oc.IdCompra AS 'ID',
    CONVERT(VARCHAR(10), oc.FechaRegistro, 103) AS 'Fecha',
    p.RazonSocial AS 'Proveedor',
    t.Nombre AS 'Tienda',
    '$' + REPLACE(CONVERT(VARCHAR, CONVERT(MONEY, oc.TotalCosto), 1), '.00', ',00') AS 'Total',
    oc.Estado
FROM ORDEN_COMPRA oc
INNER JOIN PROVEEDOR p ON oc.IdProveedor = p.IdProveedor
INNER JOIN TIENDA t ON oc.IdTienda = t.IdTienda
ORDER BY oc.IdCompra DESC

PRINT ''
PRINT '=========================================='
PRINT 'Script completado exitosamente'
PRINT '=========================================='
PRINT ''
GO
