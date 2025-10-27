-- =============================================
-- Script: Crear tabla ORDEN_PAGO
-- Descripción: Sistema de Órdenes de Pago para Facturas
-- Fecha: 2025-10-23
-- =============================================

USE DBVENTAS_WEB
GO

-- =============================================
-- CREAR TABLA ORDEN_PAGO
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ORDEN_PAGO')
BEGIN
    CREATE TABLE ORDEN_PAGO (
        IdOrdenPago INT PRIMARY KEY IDENTITY(1,1),
        NumeroOrdenPago VARCHAR(20) NOT NULL UNIQUE,
        IdFactura INT NOT NULL,
        IdProveedor INT NOT NULL,
        MetodoPago VARCHAR(100) NOT NULL,
        MontoTotal DECIMAL(18,2) NOT NULL,
        FechaRegistro DATETIME NOT NULL DEFAULT GETDATE(),
        Estado VARCHAR(20) NOT NULL DEFAULT 'Pagado',
        UsuarioRegistro VARCHAR(100) NULL,
        
        CONSTRAINT FK_OrdenPago_Factura FOREIGN KEY (IdFactura) REFERENCES FACTURA(IdFactura),
        CONSTRAINT FK_OrdenPago_Proveedor FOREIGN KEY (IdProveedor) REFERENCES PROVEEDOR(IdProveedor)
    )
    
    PRINT '✓ Tabla ORDEN_PAGO creada exitosamente'
END
ELSE
BEGIN
    PRINT '⚠ La tabla ORDEN_PAGO ya existe'
END
GO

-- =============================================
-- CREAR ÍNDICES PARA MEJOR RENDIMIENTO
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrdenPago_Factura')
BEGIN
    CREATE INDEX IX_OrdenPago_Factura ON ORDEN_PAGO(IdFactura)
    PRINT '✓ Índice IX_OrdenPago_Factura creado'
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrdenPago_Proveedor')
BEGIN
    CREATE INDEX IX_OrdenPago_Proveedor ON ORDEN_PAGO(IdProveedor)
    PRINT '✓ Índice IX_OrdenPago_Proveedor creado'
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrdenPago_Fecha')
BEGIN
    CREATE INDEX IX_OrdenPago_Fecha ON ORDEN_PAGO(FechaRegistro)
    PRINT '✓ Índice IX_OrdenPago_Fecha creado'
END
GO

PRINT ''
PRINT '========================================='
PRINT 'TABLA ORDEN_PAGO CONFIGURADA CORRECTAMENTE'
PRINT '========================================='
GO
