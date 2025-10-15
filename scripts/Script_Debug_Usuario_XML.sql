USE [DBVENTAS_WEB]
GO

-- =============================================
-- Script de diagnóstico: Ver XML del usuario
-- =============================================

-- Reemplaza el IdUsuario con el de tu usuario de prueba
DECLARE @IdUsuario INT = 1  -- Cambia esto por tu IdUsuario

PRINT 'Ejecutando usp_ObtenerDetalleUsuario para IdUsuario = ' + CAST(@IdUsuario AS VARCHAR(10))
PRINT '=========================================='
PRINT ''

-- Ejecutar el SP y ver el XML
EXEC usp_ObtenerDetalleUsuario @IdUsuario

PRINT ''
PRINT '=========================================='
PRINT 'Si el XML aparece arriba, revisa si tiene:'
PRINT '- Elemento <Usuario>'
PRINT '- Elemento <DetalleMenu>'
PRINT '- Elementos <Menu> dentro de <DetalleMenu>'
PRINT '=========================================='
GO
