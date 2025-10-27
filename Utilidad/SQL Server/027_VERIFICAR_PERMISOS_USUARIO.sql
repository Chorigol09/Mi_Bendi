USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'VERIFICACION DE PERMISOS DE USUARIO'
PRINT '========================================='
PRINT ''

-- PASO 1: Mostrar todos los usuarios
PRINT '--- USUARIOS REGISTRADOS ---'
SELECT 
    IdUsuario,
    Nombres + ' ' + Apellidos AS NombreCompleto,
    Correo,
    Clave,
    r.Descripcion AS Rol,
    u.Activo
FROM USUARIO u
INNER JOIN ROL r ON u.IdRol = r.IdRol
ORDER BY IdUsuario
GO

PRINT ''
PRINT '--- MENUS DISPONIBLES ---'
SELECT 
    m.IdMenu,
    m.Nombre AS Menu,
    m.Icono,
    m.Activo,
    COUNT(s.IdSubMenu) AS CantidadSubmenus
FROM MENU m
LEFT JOIN SUBMENU s ON m.IdMenu = s.IdMenu
GROUP BY m.IdMenu, m.Nombre, m.Icono, m.Activo
ORDER BY m.IdMenu
GO

PRINT ''
PRINT '--- PERMISOS POR ROL ---'
SELECT 
    r.IdRol,
    r.Descripcion AS Rol,
    m.Nombre AS Menu,
    COUNT(s.IdSubMenu) AS CantidadSubmenus
FROM ROL r
INNER JOIN PERMISOS p ON r.IdRol = p.IdRol
INNER JOIN MENU m ON p.IdMenu = m.IdMenu
LEFT JOIN SUBMENU s ON m.IdMenu = s.IdMenu
WHERE r.Activo = 1
GROUP BY r.IdRol, r.Descripcion, m.Nombre
ORDER BY r.IdRol, m.Nombre
GO

PRINT ''
PRINT '--- VERIFICAR MENU ORDENES DE PAGO ---'
SELECT 
    m.IdMenu,
    m.Nombre AS Menu,
    s.IdSubMenu,
    s.Nombre AS SubMenu,
    s.Controlador,
    s.Vista,
    s.Icono,
    s.Activo
FROM MENU m
LEFT JOIN SUBMENU s ON m.IdMenu = s.IdMenu
WHERE m.Nombre = 'Órdenes de Pago'
GO

PRINT ''
PRINT '--- ROLES CON ACCESO A ORDENES DE PAGO ---'
SELECT 
    r.IdRol,
    r.Descripcion AS Rol,
    m.Nombre AS Menu
FROM PERMISOS p
INNER JOIN ROL r ON p.IdRol = r.IdRol
INNER JOIN MENU m ON p.IdMenu = m.IdMenu
WHERE m.Nombre = 'Órdenes de Pago'
GO

PRINT ''
PRINT '========================================='
PRINT 'VERIFICACION COMPLETADA'
PRINT '========================================='
PRINT ''
PRINT 'Si tu usuario NO aparece con acceso a "Órdenes de Pago":'
PRINT '1. Verifica que tu rol tenga permisos (tabla anterior)'
PRINT '2. Si no tiene, ejecuta: 026_AGREGAR_MENUS_CORRECTO.sql'
PRINT '3. Cierra sesión y vuelve a entrar en la aplicación'
PRINT ''
