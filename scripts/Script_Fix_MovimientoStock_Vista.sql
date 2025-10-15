USE [DBVENTAS_WEB]
GO

-- Actualizar el submenú de Movimiento Stock para agregar la Vista
UPDATE SUBMENU
SET Vista = 'Crear'
WHERE Nombre = 'Movimiento Stock' AND Vista IS NULL

PRINT 'Vista "Crear" agregada al submenú Movimiento Stock'
GO

-- Verificar el cambio
SELECT 
    s.IdSubMenu,
    s.Nombre,
    s.Controlador,
    s.Vista,
    s.Icono,
    s.Activo
FROM SUBMENU s
WHERE s.Nombre = 'Movimiento Stock'
GO

PRINT ''
PRINT '===================================='
PRINT '✓ Corrección aplicada!'
PRINT '===================================='
PRINT 'Cierra sesión y vuelve a ingresar'
PRINT 'para que se actualice el menú.'
PRINT '===================================='
GO
