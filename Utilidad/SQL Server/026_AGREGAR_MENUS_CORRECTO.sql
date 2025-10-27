USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'AGREGANDO MENUS DE ORDEN DE PAGO'
PRINT '========================================='
PRINT ''

-- PASO 1: Verificar si ya existe el menú principal
IF NOT EXISTS (SELECT 1 FROM MENU WHERE Nombre = 'Órdenes de Pago')
BEGIN
    -- Insertar menú principal
    INSERT INTO MENU (Nombre, Icono, Activo, FechaRegistro)
    VALUES ('Órdenes de Pago', 'fas fa-money-check-alt', 1, GETDATE())
    
    PRINT '✓ Menú principal "Órdenes de Pago" creado'
END
ELSE
BEGIN
    PRINT '✓ Menú principal "Órdenes de Pago" ya existe'
END
GO

-- PASO 2: Obtener el ID del menú padre
DECLARE @IdMenuPadre INT = (SELECT IdMenu FROM MENU WHERE Nombre = 'Órdenes de Pago')

-- PASO 3: Verificar si ya existen los submenús
IF NOT EXISTS (SELECT 1 FROM SUBMENU WHERE Nombre = 'Registrar Orden de Pago' AND IdMenu = @IdMenuPadre)
BEGIN
    -- Insertar submenú Registrar
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Vista, Icono, Activo, FechaRegistro)
    VALUES (@IdMenuPadre, 'Registrar Orden de Pago', 'OrdenPago', 'Registrar', 'fas fa-plus-circle', 1, GETDATE())
    
    PRINT '✓ Submenú "Registrar Orden de Pago" creado'
END
ELSE
BEGIN
    PRINT '✓ Submenú "Registrar Orden de Pago" ya existe'
END

IF NOT EXISTS (SELECT 1 FROM SUBMENU WHERE Nombre = 'Consultar Órdenes de Pago' AND IdMenu = @IdMenuPadre)
BEGIN
    -- Insertar submenú Consultar
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Vista, Icono, Activo, FechaRegistro)
    VALUES (@IdMenuPadre, 'Consultar Órdenes de Pago', 'OrdenPago', 'Consultar', 'fas fa-list', 1, GETDATE())
    
    PRINT '✓ Submenú "Consultar Órdenes de Pago" creado'
END
ELSE
BEGIN
    PRINT '✓ Submenú "Consultar Órdenes de Pago" ya existe'
END
GO

-- PASO 4: Asignar permisos a TODOS los roles activos
DECLARE @IdMenu INT = (SELECT IdMenu FROM MENU WHERE Nombre = 'Órdenes de Pago')

PRINT ''
PRINT '--- Asignando permisos a roles ---'

-- Asignar a cada rol activo
DECLARE @IdRol INT
DECLARE rol_cursor CURSOR FOR
SELECT IdRol FROM ROL WHERE Activo = 1

OPEN rol_cursor
FETCH NEXT FROM rol_cursor INTO @IdRol

WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PERMISOS WHERE IdRol = @IdRol AND IdMenu = @IdMenu)
    BEGIN
        INSERT INTO PERMISOS (IdRol, IdMenu, FechaRegistro)
        VALUES (@IdRol, @IdMenu, GETDATE())
        
        DECLARE @DescRol VARCHAR(100) = (SELECT Descripcion FROM ROL WHERE IdRol = @IdRol)
        PRINT '✓ Permiso asignado al rol: ' + @DescRol
    END
    ELSE
    BEGIN
        DECLARE @DescRolExiste VARCHAR(100) = (SELECT Descripcion FROM ROL WHERE IdRol = @IdRol)
        PRINT '- Permiso ya existe para el rol: ' + @DescRolExiste
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
    m.Nombre AS Menu,
    p.FechaRegistro
FROM PERMISOS p
INNER JOIN ROL r ON p.IdRol = r.IdRol
INNER JOIN MENU m ON p.IdMenu = m.IdMenu
WHERE m.Nombre = 'Órdenes de Pago'
ORDER BY r.IdRol
GO

PRINT ''
PRINT '========================================='
PRINT 'COMPLETADO EXITOSAMENTE'
PRINT '========================================='
PRINT ''
PRINT 'PROXIMOS PASOS:'
PRINT '1. Cierra Visual Studio'
PRINT '2. Ejecuta: REINICIAR_IIS_Y_VS.bat'
PRINT '3. Abre Visual Studio y presiona F5'
PRINT '4. En la aplicacion: CIERRA SESION y vuelve a entrar'
PRINT '5. Deberías ver el menú "Órdenes de Pago"'
PRINT ''
GO
