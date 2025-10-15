USE [DBVENTAS_WEB]
GO

-- =============================================
-- Agregar Menú de Movimientos de Stock
-- =============================================

-- Verificar si ya existe el menú
IF NOT EXISTS (SELECT 1 FROM MENU WHERE Nombre = 'Movimientos')
BEGIN
    -- Insertar el menú principal
    INSERT INTO MENU (Nombre, Icono, UrlAccion, Activo, FechaRegistro)
    VALUES ('Movimientos', 'fas fa-exchange-alt', '#', 1, GETDATE())
    
    PRINT 'Menú "Movimientos" creado exitosamente'
END
ELSE
BEGIN
    PRINT 'El menú "Movimientos" ya existe'
END
GO

-- Obtener el ID del menú Movimientos
DECLARE @IdMenu INT
SELECT @IdMenu = IdMenu FROM MENU WHERE Nombre = 'Movimientos'

-- Verificar si ya existe el submenú
IF NOT EXISTS (SELECT 1 FROM SUBMENU WHERE Nombre = 'Movimiento Stock')
BEGIN
    -- Insertar el submenú
    INSERT INTO SUBMENU (IdMenu, Nombre, NombreURL, Controlador, VistaAccion, Icono, Activo, FechaRegistro)
    VALUES (@IdMenu, 'Movimiento Stock', 'movimientostock', 'MovimientoStock', 'Crear', 'fas fa-boxes', 1, GETDATE())
    
    PRINT 'Submenú "Movimiento Stock" creado exitosamente'
END
ELSE
BEGIN
    PRINT 'El submenú "Movimiento Stock" ya existe'
END
GO

-- Obtener el ID del submenú
DECLARE @IdSubMenu INT
SELECT @IdSubMenu = IdSubMenu FROM SUBMENU WHERE Nombre = 'Movimiento Stock'

-- Asignar permisos al rol Administrador (IdRol = 1, ajusta si es diferente)
IF NOT EXISTS (SELECT 1 FROM PERMISO WHERE IdRol = 1 AND IdSubMenu = @IdSubMenu)
BEGIN
    INSERT INTO PERMISO (IdRol, IdSubMenu, Activo, FechaRegistro)
    VALUES (1, @IdSubMenu, 1, GETDATE())
    
    PRINT 'Permiso asignado al rol Administrador'
END
ELSE
BEGIN
    PRINT 'El permiso ya existe para el rol Administrador'
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
    s.Vista,
    s.Icono AS IconoSubMenu
FROM MENU m
INNER JOIN SUBMENU s ON m.IdMenu = s.IdMenu
WHERE m.Nombre = 'Movimientos'
GO

PRINT ''
PRINT '===================================='
PRINT '✓ Menú de Movimientos creado!'
PRINT '===================================='
PRINT 'Reinicia la sesión en la aplicación'
PRINT 'para ver el nuevo menú.'
PRINT '===================================='
GO
