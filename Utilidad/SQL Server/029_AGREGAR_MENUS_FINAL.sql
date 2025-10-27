USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'AGREGANDO MENUS DE ORDEN DE PAGO'
PRINT '========================================='
PRINT ''

-- PASO 1: Crear el menú principal si no existe
IF NOT EXISTS (SELECT 1 FROM MENU WHERE Nombre = 'Órdenes de Pago')
BEGIN
    INSERT INTO MENU (Nombre, Icono, Activo, FechaRegistro)
    VALUES ('Órdenes de Pago', 'fas fa-money-check-alt', 1, GETDATE())
    
    PRINT '✓ Menú principal "Órdenes de Pago" creado'
END
ELSE
BEGIN
    PRINT '✓ Menú principal "Órdenes de Pago" ya existe'
END
GO

-- PASO 2: Obtener el ID del menú
DECLARE @IdMenu INT = (SELECT IdMenu FROM MENU WHERE Nombre = 'Órdenes de Pago')

-- PASO 3: Crear submenú Registrar si no existe
DECLARE @IdSubMenuRegistrar INT

IF NOT EXISTS (SELECT 1 FROM SUBMENU WHERE Nombre = 'Registrar Orden de Pago' AND IdMenu = @IdMenu)
BEGIN
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Vista, Icono, Activo, FechaRegistro)
    VALUES (@IdMenu, 'Registrar Orden de Pago', 'OrdenPago', 'Registrar', 'fas fa-plus-circle', 1, GETDATE())
    
    SET @IdSubMenuRegistrar = SCOPE_IDENTITY()
    PRINT '✓ Submenú "Registrar Orden de Pago" creado (ID: ' + CAST(@IdSubMenuRegistrar AS VARCHAR) + ')'
END
ELSE
BEGIN
    SET @IdSubMenuRegistrar = (SELECT IdSubMenu FROM SUBMENU WHERE Nombre = 'Registrar Orden de Pago' AND IdMenu = @IdMenu)
    PRINT '✓ Submenú "Registrar Orden de Pago" ya existe (ID: ' + CAST(@IdSubMenuRegistrar AS VARCHAR) + ')'
END

-- PASO 4: Crear submenú Consultar si no existe
DECLARE @IdSubMenuConsultar INT

IF NOT EXISTS (SELECT 1 FROM SUBMENU WHERE Nombre = 'Consultar Órdenes de Pago' AND IdMenu = @IdMenu)
BEGIN
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Vista, Icono, Activo, FechaRegistro)
    VALUES (@IdMenu, 'Consultar Órdenes de Pago', 'OrdenPago', 'Consultar', 'fas fa-list', 1, GETDATE())
    
    SET @IdSubMenuConsultar = SCOPE_IDENTITY()
    PRINT '✓ Submenú "Consultar Órdenes de Pago" creado (ID: ' + CAST(@IdSubMenuConsultar AS VARCHAR) + ')'
END
ELSE
BEGIN
    SET @IdSubMenuConsultar = (SELECT IdSubMenu FROM SUBMENU WHERE Nombre = 'Consultar Órdenes de Pago' AND IdMenu = @IdMenu)
    PRINT '✓ Submenú "Consultar Órdenes de Pago" ya existe (ID: ' + CAST(@IdSubMenuConsultar AS VARCHAR) + ')'
END

-- PASO 5: Asignar permisos a TODOS los roles activos
PRINT ''
PRINT '--- Asignando permisos a roles ---'

DECLARE @IdRol INT
DECLARE rol_cursor CURSOR FOR
SELECT IdRol FROM ROL WHERE Activo = 1

OPEN rol_cursor
FETCH NEXT FROM rol_cursor INTO @IdRol

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @DescRol VARCHAR(100) = (SELECT Descripcion FROM ROL WHERE IdRol = @IdRol)
    
    -- Asignar permiso para Registrar
    IF NOT EXISTS (SELECT 1 FROM PERMISOS WHERE IdRol = @IdRol AND IdSubMenu = @IdSubMenuRegistrar)
    BEGIN
        INSERT INTO PERMISOS (IdRol, IdSubMenu, Activo, FechaRegistro)
        VALUES (@IdRol, @IdSubMenuRegistrar, 1, GETDATE())
        
        PRINT '✓ Permiso "Registrar" asignado al rol: ' + @DescRol
    END
    
    -- Asignar permiso para Consultar
    IF NOT EXISTS (SELECT 1 FROM PERMISOS WHERE IdRol = @IdRol AND IdSubMenu = @IdSubMenuConsultar)
    BEGIN
        INSERT INTO PERMISOS (IdRol, IdSubMenu, Activo, FechaRegistro)
        VALUES (@IdRol, @IdSubMenuConsultar, 1, GETDATE())
        
        PRINT '✓ Permiso "Consultar" asignado al rol: ' + @DescRol
    END
    
    FETCH NEXT FROM rol_cursor INTO @IdRol
END

CLOSE rol_cursor
DEALLOCATE rol_cursor
GO

PRINT ''
PRINT '========================================='
PRINT 'VERIFICACION FINAL'
PRINT '========================================='
PRINT ''

-- Mostrar los menús creados
PRINT '--- Menús de Orden de Pago ---'
SELECT 
    m.IdMenu,
    m.Nombre AS Menu,
    s.IdSubMenu,
    s.Nombre AS SubMenu,
    s.Controlador,
    s.Vista,
    s.Activo
FROM MENU m
LEFT JOIN SUBMENU s ON m.IdMenu = s.IdMenu
WHERE m.Nombre = 'Órdenes de Pago'
GO

PRINT ''
PRINT '--- Permisos asignados ---'
SELECT 
    r.IdRol,
    r.Descripcion AS Rol,
    s.Nombre AS SubMenu,
    s.Controlador,
    s.Vista,
    p.Activo
FROM PERMISOS p
INNER JOIN ROL r ON p.IdRol = r.IdRol
INNER JOIN SUBMENU s ON p.IdSubMenu = s.IdSubMenu
INNER JOIN MENU m ON s.IdMenu = m.IdMenu
WHERE m.Nombre = 'Órdenes de Pago'
ORDER BY r.IdRol, s.IdSubMenu
GO

PRINT ''
PRINT '========================================='
PRINT 'COMPLETADO EXITOSAMENTE'
PRINT '========================================='
PRINT ''
PRINT 'PROXIMOS PASOS:'
PRINT '1. En Visual Studio, DETÉN la aplicación (Shift+F5)'
PRINT '2. Ejecuta: REINICIAR_IIS_Y_VS.bat'
PRINT '3. Abre Visual Studio y presiona F5'
PRINT '4. IMPORTANTE: En la aplicación, haz clic en "Salir"'
PRINT '5. Vuelve a iniciar sesión'
PRINT '6. Deberías ver el menú "Órdenes de Pago" en la barra superior'
PRINT ''
PRINT 'Si NO ves el menú:'
PRINT '- Verifica que iniciaste sesión con un usuario activo'
PRINT '- Limpia la caché del navegador (Ctrl+Shift+Delete)'
PRINT '- Cierra el navegador completamente y vuelve a abrir'
PRINT ''
GO
