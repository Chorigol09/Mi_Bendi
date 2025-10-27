USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'ACTUALIZANDO ICONO DE ORDENES DE PAGO'
PRINT '========================================='
PRINT ''

-- Actualizar el icono del menú principal
UPDATE MENU 
SET Icono = 'fas fa-money-check-alt'
WHERE Nombre = 'Órdenes de Pago' OR Nombre = 'Ordenes de Pago'

IF @@ROWCOUNT > 0
    PRINT '✓ Icono actualizado correctamente para el menú "Órdenes de Pago"'
ELSE
    PRINT '✗ No se encontró el menú "Órdenes de Pago"'

PRINT ''
PRINT '--- Verificación ---'
SELECT 
    IdMenu,
    Nombre,
    Icono,
    Activo
FROM MENU
WHERE Nombre LIKE '%Orden%Pago%'
GO

PRINT ''
PRINT '========================================='
PRINT 'COMPLETADO'
PRINT '========================================='
PRINT ''
PRINT 'NOTA: Para ver los cambios en la aplicación:'
PRINT '1. Cierra sesión en la aplicación'
PRINT '2. Vuelve a iniciar sesión'
PRINT '3. El icono debería aparecer en el menú'
PRINT ''
GO
