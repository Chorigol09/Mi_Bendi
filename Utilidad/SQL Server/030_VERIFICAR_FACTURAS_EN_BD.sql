USE DBVENTAS_WEB
GO

PRINT ''
PRINT '=========================================='
PRINT '   VERIFICACIÓN COMPLETA DE FACTURAS'
PRINT '=========================================='
PRINT ''

-- 1. Ver TODAS las facturas en la tabla (incluso inactivas)
PRINT '1. TODAS LAS FACTURAS EN LA TABLA:'
PRINT '-----------------------------------'
SELECT 
    IdFactura,
    IdProveedor,
    NumeroFactura,
    FechaEmision,
    Total,
    Estado,
    Activo
FROM FACTURA
ORDER BY IdFactura DESC
PRINT ''

-- 2. Contar facturas
PRINT '2. CONTEO DE FACTURAS:'
PRINT '-----------------------------------'
SELECT 
    COUNT(*) as TotalFacturas,
    SUM(CASE WHEN Activo = 1 THEN 1 ELSE 0 END) as FacturasActivas,
    SUM(CASE WHEN Activo = 0 THEN 1 ELSE 0 END) as FacturasInactivas
FROM FACTURA
PRINT ''

-- 3. Ver detalles de facturas
PRINT '3. DETALLES DE FACTURAS:'
PRINT '-----------------------------------'
SELECT 
    df.IdFactura,
    f.NumeroFactura,
    df.IdProducto,
    p.Nombre as Producto,
    df.Cantidad,
    df.PrecioUnitario,
    df.Subtotal,
    df.Activo
FROM DETALLE_FACTURA df
INNER JOIN FACTURA f ON df.IdFactura = f.IdFactura
INNER JOIN PRODUCTO p ON df.IdProducto = p.IdProducto
ORDER BY df.IdFactura DESC
PRINT ''

-- 4. Verificar proveedores
PRINT '4. PROVEEDORES EN FACTURAS:'
PRINT '-----------------------------------'
SELECT DISTINCT
    f.IdProveedor,
    p.RazonSocial,
    COUNT(f.IdFactura) as CantidadFacturas
FROM FACTURA f
INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
GROUP BY f.IdProveedor, p.RazonSocial
ORDER BY f.IdProveedor
PRINT ''

-- 5. Probar el SP usp_ObtenerFacturas
PRINT '5. RESULTADO DEL SP usp_ObtenerFacturas:'
PRINT '-----------------------------------'
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_ObtenerFacturas')
BEGIN
    PRINT 'Ejecutando SP...'
    EXEC usp_ObtenerFacturas
    PRINT ''
END
ELSE
BEGIN
    PRINT '✗ ERROR: El SP usp_ObtenerFacturas NO EXISTE'
    PRINT ''
END

-- 6. Ver estructura de la tabla FACTURA
PRINT '6. ESTRUCTURA DE LA TABLA FACTURA:'
PRINT '-----------------------------------'
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FACTURA'
ORDER BY ORDINAL_POSITION
PRINT ''

-- 7. Verificar si hay columna Observaciones
PRINT '7. VERIFICAR COLUMNA OBSERVACIONES:'
PRINT '-----------------------------------'
IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'FACTURA' AND COLUMN_NAME = 'Observaciones'
)
BEGIN
    PRINT '✓ La columna Observaciones EXISTE'
END
ELSE
BEGIN
    PRINT '✗ La columna Observaciones NO EXISTE'
    PRINT 'SOLUCIÓN: Ejecutar el siguiente comando:'
    PRINT 'ALTER TABLE FACTURA ADD Observaciones VARCHAR(500) NULL'
END
PRINT ''

-- 8. Última factura registrada
PRINT '8. ÚLTIMA FACTURA REGISTRADA:'
PRINT '-----------------------------------'
SELECT TOP 1
    IdFactura,
    NumeroFactura,
    FechaEmision,
    Total,
    Estado,
    Activo
FROM FACTURA
ORDER BY IdFactura DESC
PRINT ''

PRINT '=========================================='
PRINT 'FIN DE LA VERIFICACIÓN'
PRINT '=========================================='
PRINT ''
PRINT 'INTERPRETACIÓN DE RESULTADOS:'
PRINT '- Si hay facturas en la tabla pero el SP no devuelve nada:'
PRINT '  → Problema con el SP usp_ObtenerFacturas'
PRINT '- Si NO hay facturas en la tabla:'
PRINT '  → Problema con el registro (SP usp_RegistrarFacturaConDetalles)'
PRINT '- Si falta la columna Observaciones:'
PRINT '  → Ejecutar el ALTER TABLE mostrado arriba'
PRINT ''
GO
