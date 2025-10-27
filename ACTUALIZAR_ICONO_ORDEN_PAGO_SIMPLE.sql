-- ========================================
-- ACTUALIZAR ICONO DE ORDENES DE PAGO
-- ========================================
-- Instrucciones:
-- 1. Abre SQL Server Management Studio
-- 2. Conectate a tu servidor
-- 3. Copia y pega este script completo
-- 4. Ejecuta (F5)
-- ========================================

USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'ACTUALIZANDO ICONO DE ORDENES DE PAGO'
PRINT '========================================='
PRINT ''

-- Verificar el estado actual
PRINT '--- Estado Actual ---'
SELECT 
    IdMenu,
    Nombre,
    Icono,
    Activo
FROM MENU
WHERE Nombre LIKE '%Orden%Pago%'
GO

-- Actualizar el icono del menú principal
UPDATE MENU 
SET Icono = 'fas fa-money-check-alt'
WHERE Nombre IN ('Órdenes de Pago', 'Ordenes de Pago')

PRINT ''
PRINT '--- Actualización Realizada ---'

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
PRINT 'PASOS SIGUIENTES:'
PRINT '1. En la aplicacion web, haz clic en "Salir"'
PRINT '2. Vuelve a iniciar sesion'
PRINT '3. El icono deberia aparecer en el menu'
PRINT ''
GO
