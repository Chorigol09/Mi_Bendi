USE [DBVENTAS_WEB]
GO

-- =============================================
-- Agregar columna MetodoPago a tabla VENTA
-- =============================================

-- Verificar si la columna ya existe
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID(N'[dbo].[VENTA]') 
               AND name = 'MetodoPago')
BEGIN
    -- Agregar columna MetodoPago
    ALTER TABLE VENTA
    ADD MetodoPago VARCHAR(50) NULL
    
    PRINT 'Columna MetodoPago agregada exitosamente a la tabla VENTA'
END
ELSE
BEGIN
    PRINT 'La columna MetodoPago ya existe en la tabla VENTA'
END
GO

-- Actualizar registros existentes con valor por defecto (en transacción separada)
UPDATE VENTA
SET MetodoPago = 'Efectivo'
WHERE MetodoPago IS NULL

PRINT 'Registros existentes actualizados con MetodoPago = Efectivo'
GO
