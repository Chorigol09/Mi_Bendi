-- =============================================
-- Script: Agregar campos de Referencia y Numero Transaccion
-- Descripcion: Para metodos de pago que no sean efectivo
-- Fecha: 2025-11-10
-- =============================================

USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'AGREGANDO CAMPOS A ORDEN_PAGO'
PRINT '========================================='
PRINT ''

-- =============================================
-- Agregar columna Referencia
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('ORDEN_PAGO') AND name = 'Referencia')
BEGIN
    ALTER TABLE ORDEN_PAGO ADD Referencia VARCHAR(100) NULL
    PRINT '✓ Columna Referencia agregada'
END
ELSE
BEGIN
    PRINT '⚠ Columna Referencia ya existe'
END
GO

-- =============================================
-- Agregar columna NumeroTransaccion
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('ORDEN_PAGO') AND name = 'NumeroTransaccion')
BEGIN
    ALTER TABLE ORDEN_PAGO ADD NumeroTransaccion VARCHAR(100) NULL
    PRINT '✓ Columna NumeroTransaccion agregada'
END
ELSE
BEGIN
    PRINT '⚠ Columna NumeroTransaccion ya existe'
END
GO

PRINT ''
PRINT '========================================='
PRINT 'CAMPOS AGREGADOS EXITOSAMENTE'
PRINT '========================================='
PRINT ''
PRINT 'Campos agregados:'
PRINT '- Referencia: Para numero de comprobante o ultimos 4 digitos tarjeta'
PRINT '- NumeroTransaccion: Para identificador de transaccion'
PRINT ''
PRINT 'Proximo paso: Ejecutar 054_SP_ORDEN_PAGO_REFERENCIA.sql'
PRINT '========================================='
GO
