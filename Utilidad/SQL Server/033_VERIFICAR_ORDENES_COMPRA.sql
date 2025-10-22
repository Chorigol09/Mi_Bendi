USE DBVENTAS_WEB
GO

PRINT '=========================================='
PRINT 'DIAGNÓSTICO ÓRDENES DE COMPRA'
PRINT '=========================================='
PRINT ''

-- 1. Ver todas las órdenes de compra
PRINT '1. ÓRDENES DE COMPRA EN LA TABLA:'
PRINT '-----------------------------------'
SELECT 
    IdCompra,
    IdUsuario,
    IdProveedor,
    IdTienda,
    TotalCosto,
    TipoComprobante,
    Activo,
    FechaRegistro,
    Estado
FROM ORDEN_COMPRA
ORDER BY IdCompra DESC
PRINT ''

-- 2. Contar órdenes
PRINT '2. CONTEO DE ÓRDENES:'
PRINT '-----------------------------------'
SELECT 
    COUNT(*) as TotalOrdenes,
    SUM(CASE WHEN Activo = 1 THEN 1 ELSE 0 END) as Activas,
    SUM(CASE WHEN Activo = 0 THEN 1 ELSE 0 END) as Inactivas,
    SUM(CASE WHEN Estado = 'Abierta' THEN 1 ELSE 0 END) as Abiertas
FROM ORDEN_COMPRA
PRINT ''

-- 3. Verificar SP
PRINT '3. VERIFICANDO SP usp_ObtenerCompras:'
PRINT '-----------------------------------'
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_ObtenerCompras')
BEGIN
    PRINT '✓ SP existe'
    PRINT ''
    PRINT 'Probando SP (últimas 5 órdenes):'
    EXEC usp_ObtenerCompras 
        @fechainicio = '2024-01-01',
        @fechafin = '2025-12-31',
        @idproveedor = 0,
        @idtienda = 0
END
ELSE
BEGIN
    PRINT '✗ SP NO existe'
END
PRINT ''

PRINT '=========================================='
PRINT 'FIN DEL DIAGNÓSTICO'
PRINT '=========================================='
GO
