USE DBVENTAS_WEB
GO

PRINT '=========================================='
PRINT 'DIAGNÓSTICO DE VENTAS'
PRINT '=========================================='
PRINT ''

-- 1. Verificar si hay ventas
PRINT '1. VENTAS EN LA BASE DE DATOS:'
PRINT '-----------------------------------'
SELECT COUNT(*) as 'Total Ventas' FROM VENTA
PRINT ''

-- 2. Ver las ventas más recientes
PRINT '2. ÚLTIMAS 10 VENTAS:'
PRINT '-----------------------------------'
SELECT TOP 10
    v.IdVenta,
    v.TipoDocumento,
    v.Codigo,
    v.FechaRegistro,
    c.NumeroDocumento,
    c.Nombre as Cliente,
    v.TotalCosto
FROM VENTA v
INNER JOIN CLIENTE c ON v.IdCliente = c.IdCliente
ORDER BY v.IdVenta DESC
PRINT ''

-- 3. Verificar que el SP existe
PRINT '3. VERIFICAR STORED PROCEDURE:'
PRINT '-----------------------------------'
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_ObtenerListaVenta')
    PRINT '✓ SP usp_ObtenerListaVenta existe'
ELSE
    PRINT '✗ ERROR: SP usp_ObtenerListaVenta NO EXISTE'
PRINT ''

-- 4. Probar el SP con fechas de hoy
PRINT '4. PROBANDO SP CON RANGO DE FECHAS AMPLIO:'
PRINT '-----------------------------------'
DECLARE @FechaInicio DATE = DATEADD(MONTH, -6, GETDATE())
DECLARE @FechaFin DATE = GETDATE()

EXEC usp_ObtenerListaVenta 
    @Codigo = '',
    @FechaInicio = @FechaInicio,
    @FechaFin = @FechaFin,
    @NumeroDocumento = '',
    @Nombre = ''
PRINT ''

PRINT '=========================================='
PRINT 'FIN DEL DIAGNÓSTICO'
PRINT '=========================================='
