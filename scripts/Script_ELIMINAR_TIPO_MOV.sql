USE [DBVENTAS_WEB]
GO

PRINT 'Iniciando eliminacion de TIPO_MOV...'
GO

-- 1. Eliminar TODOS los constraints FK que referencian a TIPO_MOV
DECLARE @SQL NVARCHAR(MAX) = ''

SELECT @SQL = @SQL + 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + 
              QUOTENAME(OBJECT_NAME(parent_object_id)) + 
              ' DROP CONSTRAINT ' + QUOTENAME(name) + '; '
FROM sys.foreign_keys
WHERE referenced_object_id = OBJECT_ID('TIPO_MOV')

IF @SQL <> ''
BEGIN
    PRINT 'Eliminando constraints FK que referencian TIPO_MOV...'
    PRINT @SQL
    EXEC sp_executesql @SQL
    PRINT 'Constraints eliminados'
END
ELSE
BEGIN
    PRINT 'No hay constraints FK que referencien a TIPO_MOV'
END
GO

-- 2. Eliminar columna IdTipoMov de MOVIMIENTO_STOCK
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'MOVIMIENTO_STOCK' AND COLUMN_NAME = 'IdTipoMov')
BEGIN
    PRINT 'Eliminando columna IdTipoMov...'
    ALTER TABLE MOVIMIENTO_STOCK DROP COLUMN IdTipoMov
    PRINT 'Columna eliminada'
END
GO

-- 3. Eliminar tabla TIPO_MOV
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TIPO_MOV]') AND type in (N'U'))
BEGIN
    PRINT 'Eliminando tabla TIPO_MOV...'
    DROP TABLE [dbo].[TIPO_MOV]
    PRINT 'Tabla eliminada'
END
ELSE
BEGIN
    PRINT 'La tabla TIPO_MOV no existe'
END
GO

PRINT 'Proceso completado exitosamente'
GO
