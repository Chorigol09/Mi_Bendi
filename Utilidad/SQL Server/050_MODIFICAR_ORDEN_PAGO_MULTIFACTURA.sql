-- =============================================
-- Script: Modificar ORDEN_PAGO para múltiples facturas
-- Descripción: Permite asociar múltiples facturas a una orden de pago
-- Fecha: 2025-11-10
-- =============================================

USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'INICIANDO MODIFICACIÓN DE ORDEN_PAGO'
PRINT '========================================='
PRINT ''

-- =============================================
-- PASO 1: Crear tabla DETALLE_ORDEN_PAGO
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DETALLE_ORDEN_PAGO')
BEGIN
    CREATE TABLE DETALLE_ORDEN_PAGO (
        IdDetalleOrdenPago INT PRIMARY KEY IDENTITY(1,1),
        IdOrdenPago INT NOT NULL,
        IdFactura INT NOT NULL,
        MontoFactura DECIMAL(18,2) NOT NULL,
        
        CONSTRAINT FK_DetalleOrdenPago_OrdenPago FOREIGN KEY (IdOrdenPago) REFERENCES ORDEN_PAGO(IdOrdenPago),
        CONSTRAINT FK_DetalleOrdenPago_Factura FOREIGN KEY (IdFactura) REFERENCES FACTURA(IdFactura),
        CONSTRAINT UQ_DetalleOrdenPago_Factura UNIQUE (IdFactura) -- Una factura solo puede estar en una orden
    )
    
    PRINT '✓ Tabla DETALLE_ORDEN_PAGO creada exitosamente'
END
ELSE
BEGIN
    PRINT '⚠ La tabla DETALLE_ORDEN_PAGO ya existe'
END
GO

-- =============================================
-- PASO 2: Migrar datos existentes
-- =============================================
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ORDEN_PAGO' AND name = 'DETALLE_ORDEN_PAGO')
BEGIN
    -- Solo migrar si DETALLE_ORDEN_PAGO está vacío y ORDEN_PAGO tiene datos
    IF NOT EXISTS (SELECT 1 FROM DETALLE_ORDEN_PAGO) AND EXISTS (SELECT 1 FROM ORDEN_PAGO)
    BEGIN
        PRINT 'Migrando datos existentes...'
        
        INSERT INTO DETALLE_ORDEN_PAGO (IdOrdenPago, IdFactura, MontoFactura)
        SELECT 
            IdOrdenPago,
            IdFactura,
            MontoTotal
        FROM ORDEN_PAGO
        WHERE IdFactura IS NOT NULL
        
        PRINT '✓ Datos migrados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros'
    END
    ELSE
    BEGIN
        PRINT '⚠ No se requiere migración de datos'
    END
END
GO

-- =============================================
-- PASO 3: Eliminar FK e índice de IdFactura en ORDEN_PAGO
-- =============================================
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_OrdenPago_Factura')
BEGIN
    ALTER TABLE ORDEN_PAGO DROP CONSTRAINT FK_OrdenPago_Factura
    PRINT '✓ Foreign Key FK_OrdenPago_Factura eliminada'
END
GO

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrdenPago_Factura')
BEGIN
    DROP INDEX IX_OrdenPago_Factura ON ORDEN_PAGO
    PRINT '✓ Índice IX_OrdenPago_Factura eliminado'
END
GO

-- =============================================
-- PASO 4: Hacer IdFactura nullable (mantener para compatibilidad temporal)
-- =============================================
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('ORDEN_PAGO') AND name = 'IdFactura')
BEGIN
    -- Verificar si la columna ya es nullable
    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('ORDEN_PAGO') AND name = 'IdFactura' AND is_nullable = 0)
    BEGIN
        ALTER TABLE ORDEN_PAGO ALTER COLUMN IdFactura INT NULL
        PRINT '✓ Columna IdFactura modificada a nullable'
    END
    ELSE
    BEGIN
        PRINT '⚠ Columna IdFactura ya es nullable'
    END
END
GO

-- =============================================
-- PASO 5: Crear índices para DETALLE_ORDEN_PAGO
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DetalleOrdenPago_OrdenPago')
BEGIN
    CREATE INDEX IX_DetalleOrdenPago_OrdenPago ON DETALLE_ORDEN_PAGO(IdOrdenPago)
    PRINT '✓ Índice IX_DetalleOrdenPago_OrdenPago creado'
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DetalleOrdenPago_Factura')
BEGIN
    CREATE INDEX IX_DetalleOrdenPago_Factura ON DETALLE_ORDEN_PAGO(IdFactura)
    PRINT '✓ Índice IX_DetalleOrdenPago_Factura creado'
END
GO

PRINT ''
PRINT '========================================='
PRINT 'MODIFICACIÓN COMPLETADA EXITOSAMENTE'
PRINT '========================================='
PRINT 'PRÓXIMOS PASOS:'
PRINT '1. Ejecutar script 051_SP_ORDEN_PAGO_MULTIFACTURA.sql'
PRINT '2. Actualizar código C# y frontend'
PRINT '========================================='
GO
