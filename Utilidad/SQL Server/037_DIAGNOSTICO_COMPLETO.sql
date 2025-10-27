USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'DIAGNOSTICO COMPLETO - FACTURAS'
PRINT '========================================='
PRINT ''

-- PASO 1: Verificar que existen facturas pendientes
PRINT '--- PASO 1: FACTURAS PENDIENTES EN LA BD ---'
SELECT 
    f.IdFactura,
    f.NumeroFactura,
    f.IdProveedor,
    p.RazonSocial,
    f.Estado,
    f.Total
FROM FACTURA f
LEFT JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
WHERE f.Estado = 'Pendiente'
GO

PRINT ''
PRINT '--- PASO 2: CONTAR FACTURAS POR PROVEEDOR ---'
SELECT 
    p.IdProveedor,
    p.RazonSocial,
    COUNT(f.IdFactura) AS CantidadPendientes
FROM PROVEEDOR p
LEFT JOIN FACTURA f ON p.IdProveedor = f.IdProveedor AND f.Estado = 'Pendiente'
WHERE p.Activo = 1
GROUP BY p.IdProveedor, p.RazonSocial
ORDER BY CantidadPendientes DESC
GO

PRINT ''
PRINT '--- PASO 3: VERIFICAR TABLA ORDEN_PAGO ---'
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ORDEN_PAGO')
BEGIN
    PRINT '✓ Tabla ORDEN_PAGO existe'
    SELECT COUNT(*) AS TotalOrdenesPago FROM ORDEN_PAGO
    
    PRINT ''
    PRINT '--- Facturas que ya tienen orden de pago ---'
    SELECT 
        op.IdOrdenPago,
        op.IdFactura,
        f.NumeroFactura,
        f.Estado
    FROM ORDEN_PAGO op
    INNER JOIN FACTURA f ON op.IdFactura = f.IdFactura
END
ELSE
BEGIN
    PRINT '✗ Tabla ORDEN_PAGO NO existe'
END
GO

PRINT ''
PRINT '--- PASO 4: PROBAR SP CON PROVEEDOR ID 1 ---'
EXEC SP_OBTENER_FACTURAS_PENDIENTES 1
GO

PRINT ''
PRINT '--- PASO 5: PROBAR SP CON PROVEEDOR ID 2 ---'
EXEC SP_OBTENER_FACTURAS_PENDIENTES 2
GO

PRINT ''
PRINT '--- PASO 6: PROBAR SP CON PROVEEDOR ID 3 ---'
EXEC SP_OBTENER_FACTURAS_PENDIENTES 3
GO

PRINT ''
PRINT '--- PASO 7: VERIFICAR CONDICIONES DEL SP ---'
PRINT 'El SP busca facturas que cumplan:'
PRINT '1. IdProveedor = @IdProveedor'
PRINT '2. Estado = Pendiente'
PRINT '3. NO existe en ORDEN_PAGO'
PRINT ''

-- Verificar facturas que cumplen las 3 condiciones
SELECT 
    f.IdFactura,
    f.NumeroFactura,
    f.IdProveedor,
    p.RazonSocial,
    f.Estado,
    CASE 
        WHEN EXISTS(SELECT 1 FROM ORDEN_PAGO WHERE IdFactura = f.IdFactura) 
        THEN 'SI' 
        ELSE 'NO' 
    END AS TieneOrdenPago
FROM FACTURA f
INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
WHERE f.Estado = 'Pendiente'
ORDER BY f.IdProveedor
GO

PRINT ''
PRINT '========================================='
PRINT 'ANALISIS COMPLETO'
PRINT '========================================='
