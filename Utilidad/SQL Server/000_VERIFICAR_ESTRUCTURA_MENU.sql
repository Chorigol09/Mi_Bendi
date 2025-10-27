USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'VERIFICANDO ESTRUCTURA DE TABLAS'
PRINT '========================================='
PRINT ''

-- Verificar estructura de MENU
PRINT '--- ESTRUCTURA DE TABLA MENU ---'
SELECT 
    COLUMN_NAME AS Columna,
    DATA_TYPE AS Tipo,
    IS_NULLABLE AS Nulo
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'MENU'
ORDER BY ORDINAL_POSITION
GO

PRINT ''
PRINT '--- ESTRUCTURA DE TABLA SUBMENU ---'
SELECT 
    COLUMN_NAME AS Columna,
    DATA_TYPE AS Tipo,
    IS_NULLABLE AS Nulo
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SUBMENU'
ORDER BY ORDINAL_POSITION
GO

PRINT ''
PRINT '--- MENUS EXISTENTES ---'
SELECT 
    IdMenu,
    Nombre,
    Icono,
    Activo
FROM MENU
ORDER BY IdMenu
GO

PRINT ''
PRINT '--- SUBMENUS EXISTENTES ---'
SELECT 
    s.IdSubMenu,
    m.Nombre AS MenuPadre,
    s.Nombre AS SubMenu,
    s.Controlador,
    s.Vista,
    s.Icono,
    s.Activo
FROM SUBMENU s
INNER JOIN MENU m ON s.IdMenu = m.IdMenu
ORDER BY m.IdMenu, s.IdSubMenu
GO

PRINT ''
PRINT '========================================='
PRINT 'VERIFICACION COMPLETADA'
PRINT '========================================='
