USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'VERIFICACION Y ASIGNACION DE PERMISOS'
PRINT '========================================='
PRINT ''

-- PASO 1: Verificar que los menús existen
PRINT '--- PASO 1: Verificar menús ---'
SELECT 
    m.IdMenu,
    m.Nombre AS Menu,
    m.Icono,
    m.Activo,
    s.IdSubMenu,
    s.Nombre AS SubMenu,
    s.Controlador,
    s.Vista,
    s.Activo AS SubMenuActivo
FROM MENU m
LEFT JOIN SUBMENU s ON m.IdMenu = s.IdMenu
WHERE m.Nombre = 'Órdenes de Pago'
GO

PRINT ''
PRINT '--- PASO 2: Verificar roles existentes ---'
SELECT IdRol, Nombre, Activo FROM ROL
GO

PRINT ''
PRINT '--- PASO 3: Asignar permisos a TODOS los roles activos ---'

-- Obtener el ID del menú
DECLARE @IdMenu INT = (SELECT IdMenu FROM MENU WHERE Nombre = 'Órdenes de Pago')

IF @IdMenu IS NULL
BEGIN
    PRINT 'ERROR: El menú "Órdenes de Pago" no existe'
    PRINT 'Ejecuta primero: 023_AGREGAR_MENUS_ORDEN_PAGO_CORRECTO.sql'
END
ELSE
BEGIN
    -- Asignar a todos los roles activos
    DECLARE @IdRol INT
    DECLARE rol_cursor CURSOR FOR
    SELECT IdRol FROM ROL WHERE Activo = 1
    
    OPEN rol_cursor
    FETCH NEXT FROM rol_cursor INTO @IdRol
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM MENU_ROL WHERE IdMenu = @IdMenu AND IdRol = @IdRol)
        BEGIN
            INSERT INTO MENU_ROL (IdMenu, IdRol, FechaRegistro)
            VALUES (@IdMenu, @IdRol, GETDATE())
            
            DECLARE @NombreRol VARCHAR(100) = (SELECT Nombre FROM ROL WHERE IdRol = @IdRol)
            PRINT '✓ Permiso asignado al rol: ' + @NombreRol
        END
        ELSE
        BEGIN
            DECLARE @NombreRolExiste VARCHAR(100) = (SELECT Nombre FROM ROL WHERE IdRol = @IdRol)
            PRINT '- Permiso ya existe para el rol: ' + @NombreRolExiste
        END
        
        FETCH NEXT FROM rol_cursor INTO @IdRol
    END
    
    CLOSE rol_cursor
    DEALLOCATE rol_cursor
END
GO

PRINT ''
PRINT '--- PASO 4: Verificar permisos asignados ---'
SELECT 
    r.IdRol,
    r.Nombre AS Rol,
    m.Nombre AS Menu,
    mr.FechaRegistro
FROM MENU_ROL mr
INNER JOIN ROL r ON mr.IdRol = r.IdRol
INNER JOIN MENU m ON mr.IdMenu = m.IdMenu
WHERE m.Nombre = 'Órdenes de Pago'
ORDER BY r.IdRol
GO

PRINT ''
PRINT '--- PASO 5: Verificar usuarios y sus roles ---'
SELECT 
    u.IdUsuario,
    u.NombreUsuario,
    u.Correo,
    r.Nombre AS Rol,
    u.Activo
FROM USUARIO u
INNER JOIN ROL r ON u.IdRol = r.IdRol
WHERE u.Activo = 1
ORDER BY u.IdUsuario
GO

PRINT ''
PRINT '========================================='
PRINT 'VERIFICACION COMPLETADA'
PRINT '========================================='
PRINT ''
PRINT 'IMPORTANTE:'
PRINT '1. Verifica que tu usuario aparece en la lista del PASO 5'
PRINT '2. Verifica que tu rol tiene permisos en el PASO 4'
PRINT '3. Cierra sesión en la aplicación'
PRINT '4. Vuelve a iniciar sesión'
PRINT '5. Deberías ver el menú "Órdenes de Pago"'
PRINT ''
GO
