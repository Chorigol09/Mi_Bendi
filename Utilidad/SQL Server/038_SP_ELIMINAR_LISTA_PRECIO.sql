-- =============================================
-- Script: 038_SP_ELIMINAR_LISTA_PRECIO.sql
-- Descripcion: Stored procedure para eliminar una lista de precios
--              Elimina primero todos los productos asociados y luego la lista
-- Fecha: 12/11/2024
-- =============================================

USE DBVENTAS_WEB
GO

-- Verificar si el SP ya existe y eliminarlo
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EliminarListaPrecio')
BEGIN
    DROP PROCEDURE usp_EliminarListaPrecio
    PRINT 'Stored Procedure usp_EliminarListaPrecio eliminado'
END
GO

-- Crear el Stored Procedure
CREATE PROCEDURE usp_EliminarListaPrecio
    @IdListaPrecio INT,
    @Resultado BIT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    
    BEGIN TRANSACTION
    
    BEGIN TRY
        -- Verificar que la lista existe
        IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO WHERE IdListaPrecio = @IdListaPrecio)
        BEGIN
            SET @Mensaje = 'La lista de precios no existe'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        DECLARE @NombreLista VARCHAR(100)
        DECLARE @CantidadProductos INT
        
        SELECT @NombreLista = Nombre FROM LISTA_PRECIO WHERE IdListaPrecio = @IdListaPrecio
        SELECT @CantidadProductos = COUNT(*) FROM LISTA_PRECIO_DETALLE WHERE IdListaPrecio = @IdListaPrecio
        
        -- Eliminar todos los productos de la lista (borrado fisico)
        DELETE FROM LISTA_PRECIO_DETALLE
        WHERE IdListaPrecio = @IdListaPrecio
        
        -- Eliminar la lista de precios (borrado fisico)
        DELETE FROM LISTA_PRECIO
        WHERE IdListaPrecio = @IdListaPrecio
        
        COMMIT TRANSACTION
        
        SET @Resultado = 1
        SET @Mensaje = 'Lista "' + @NombreLista + '" eliminada correctamente'
        
        IF @CantidadProductos > 0
        BEGIN
            SET @Mensaje = @Mensaje + ' (' + CAST(@CantidadProductos AS VARCHAR) + ' productos eliminados)'
        END
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SET @Resultado = 0
        SET @Mensaje = 'Error al eliminar la lista: ' + ERROR_MESSAGE()
    END CATCH
END
GO

PRINT ''
PRINT '==========================================='
PRINT 'Stored Procedure usp_EliminarListaPrecio creado exitosamente'
PRINT '==========================================='
PRINT ''

-- Prueba del SP (comentar si no quieres ejecutar)
/*
DECLARE @resultado BIT
DECLARE @mensaje VARCHAR(500)

-- Ejecutar SP (cambiar el ID por uno que exista)
EXEC usp_EliminarListaPrecio 
    @IdListaPrecio = 999,  -- Cambiar por ID valido
    @Resultado = @resultado OUTPUT,
    @Mensaje = @mensaje OUTPUT

-- Mostrar resultado
PRINT 'Resultado: ' + CAST(@resultado AS VARCHAR)
PRINT 'Mensaje: ' + @mensaje
*/

GO
