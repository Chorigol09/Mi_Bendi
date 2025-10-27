USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'INSERTAR FACTURAS DE PRUEBA'
PRINT '========================================='
PRINT ''

-- Verificar que existan proveedores
IF NOT EXISTS (SELECT 1 FROM PROVEEDOR WHERE Activo = 1)
BEGIN
    PRINT 'ERROR: No hay proveedores activos'
    PRINT 'Primero debes crear proveedores en la aplicacion'
    RETURN
END

-- Obtener el primer proveedor activo
DECLARE @IdProveedor INT = (SELECT TOP 1 IdProveedor FROM PROVEEDOR WHERE Activo = 1)
DECLARE @RazonSocial VARCHAR(100) = (SELECT RazonSocial FROM PROVEEDOR WHERE IdProveedor = @IdProveedor)

PRINT 'Usando proveedor: ' + @RazonSocial + ' (ID: ' + CAST(@IdProveedor AS VARCHAR) + ')'
PRINT ''

-- Insertar facturas de prueba solo si no existen
IF NOT EXISTS (SELECT 1 FROM FACTURA WHERE NumeroFactura = 'FACT-001-2025')
BEGIN
    INSERT INTO FACTURA (NumeroFactura, FechaEmision, IdProveedor, Total, Estado, FechaRegistro)
    VALUES ('FACT-001-2025', DATEADD(DAY, -30, GETDATE()), @IdProveedor, 1500.00, 'Pendiente', GETDATE())
    PRINT '✓ Factura FACT-001-2025 creada (S/ 1,500.00 - Pendiente)'
END
ELSE
    PRINT '- Factura FACT-001-2025 ya existe'

IF NOT EXISTS (SELECT 1 FROM FACTURA WHERE NumeroFactura = 'FACT-002-2025')
BEGIN
    INSERT INTO FACTURA (NumeroFactura, FechaEmision, IdProveedor, Total, Estado, FechaRegistro)
    VALUES ('FACT-002-2025', DATEADD(DAY, -20, GETDATE()), @IdProveedor, 2800.50, 'Pendiente', GETDATE())
    PRINT '✓ Factura FACT-002-2025 creada (S/ 2,800.50 - Pendiente)'
END
ELSE
    PRINT '- Factura FACT-002-2025 ya existe'

IF NOT EXISTS (SELECT 1 FROM FACTURA WHERE NumeroFactura = 'FACT-003-2025')
BEGIN
    INSERT INTO FACTURA (NumeroFactura, FechaEmision, IdProveedor, Total, Estado, FechaRegistro)
    VALUES ('FACT-003-2025', DATEADD(DAY, -10, GETDATE()), @IdProveedor, 950.75, 'Pendiente', GETDATE())
    PRINT '✓ Factura FACT-003-2025 creada (S/ 950.75 - Pendiente)'
END
ELSE
    PRINT '- Factura FACT-003-2025 ya existe'

IF NOT EXISTS (SELECT 1 FROM FACTURA WHERE NumeroFactura = 'FACT-004-2025')
BEGIN
    INSERT INTO FACTURA (NumeroFactura, FechaEmision, IdProveedor, Total, Estado, FechaRegistro)
    VALUES ('FACT-004-2025', DATEADD(DAY, -5, GETDATE()), @IdProveedor, 3200.00, 'Pendiente', GETDATE())
    PRINT '✓ Factura FACT-004-2025 creada (S/ 3,200.00 - Pendiente)'
END
ELSE
    PRINT '- Factura FACT-004-2025 ya existe'

GO

PRINT ''
PRINT '========================================='
PRINT 'FACTURAS CREADAS'
PRINT '========================================='
PRINT ''

-- Mostrar facturas creadas
SELECT 
    f.IdFactura,
    f.NumeroFactura,
    f.FechaEmision,
    p.RazonSocial AS Proveedor,
    f.Total,
    f.Estado
FROM FACTURA f
INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
WHERE f.NumeroFactura LIKE 'FACT-%2025'
ORDER BY f.IdFactura DESC
GO

PRINT ''
PRINT 'NOTA: Estas son facturas de prueba'
PRINT 'Puedes usarlas para probar el modulo de Orden de Pago'
PRINT ''
