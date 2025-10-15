USE [DBVENTAS_WEB]
GO

-- =============================================
-- Verificar estructura de tablas
-- =============================================
PRINT 'Columnas de MENU:'
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'MENU'
GO

PRINT ''
PRINT 'Columnas de SUBMENU:'
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SUBMENU'
GO

PRINT ''
PRINT 'Columnas de PERMISOS (o similar):'
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE '%PERMISO%'
GO

-- =============================================
-- Agregar Menú de Movimientos de Stock
-- (Ajustar según la estructura real)
-- =============================================

-- Verificar si ya existe el menú
IF NOT EXISTS (SELECT 1 FROM MENU WHERE Nombre = 'Movimientos')
BEGIN
    -- Insertar el menú principal (ajusta las columnas según tu estructura)
    INSERT INTO MENU (Nombre, Icono, Activo, FechaRegistro)
    VALUES ('Movimientos', 'fas fa-exchange-alt', 1, GETDATE())
    
    PRINT ''
    PRINT 'Menú "Movimientos" creado'
END
ELSE
BEGIN
    PRINT ''
    PRINT 'El menú "Movimientos" ya existe'
END
GO

-- Obtener el ID del menú Movimientos
DECLARE @IdMenu INT
SELECT @IdMenu = IdMenu FROM MENU WHERE Nombre = 'Movimientos'

-- Verificar si ya existe el submenú
IF NOT EXISTS (SELECT 1 FROM SUBMENU WHERE Nombre = 'Movimiento Stock')
BEGIN
    -- Insertar el submenú (ajusta las columnas según tu estructura)
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Icono, Activo, FechaRegistro)
    VALUES (@IdMenu, 'Movimiento Stock', 'MovimientoStock', 'fas fa-boxes', 1, GETDATE())
    
    PRINT 'Submenú "Movimiento Stock" creado'
END
ELSE
BEGIN
    PRINT 'El submenú "Movimiento Stock" ya existe'
END
GO

-- Mostrar menú creado
SELECT 
    m.IdMenu,
    m.Nombre AS Menu,
    m.Icono AS IconoMenu,
    s.IdSubMenu,
    s.Nombre AS SubMenu,
    s.Controlador,
    s.Icono AS IconoSubMenu
FROM MENU m
INNER JOIN SUBMENU s ON m.IdMenu = s.IdMenu
WHERE m.Nombre = 'Movimientos'
GO

PRINT ''
PRINT '===================================='
PRINT 'Por favor revisa las columnas mostradas arriba'
PRINT 'y comparte los resultados para ajustar'
PRINT 'el script de permisos.'
PRINT '===================================='
GO
