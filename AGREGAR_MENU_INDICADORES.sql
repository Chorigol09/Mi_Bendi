USE DBVENTAS_WEB
GO

-- Verificar si ya existe el submenú de Indicadores
IF NOT EXISTS (SELECT * FROM SUBMENU WHERE Nombre = 'Indicadores')
BEGIN
    -- Obtener el IdMenu de Reportes
    DECLARE @IdMenuReportes INT
    SELECT @IdMenuReportes = IdMenu FROM MENU WHERE Nombre = 'Reportes'
    
    IF @IdMenuReportes IS NOT NULL
    BEGIN
        -- Insertar el submenú de Indicadores
        INSERT INTO SUBMENU (IdMenu, Nombre, Icono, Controlador, Vista, Activo)
        VALUES (@IdMenuReportes, 'Indicadores', 'fas fa-chart-line', 'Indicadores', 'Index', 1)
        
        PRINT 'Submenú "Indicadores" agregado exitosamente'
    END
    ELSE
    BEGIN
        PRINT 'No se encontró el menú "Reportes". Creando menú completo...'
        
        -- Crear el menú Reportes si no existe
        INSERT INTO MENU (Nombre, Icono, Activo)
        VALUES ('Reportes', 'fas fa-chart-bar', 1)
        
        SELECT @IdMenuReportes = SCOPE_IDENTITY()
        
        -- Insertar el submenú de Indicadores
        INSERT INTO SUBMENU (IdMenu, Nombre, Icono, Controlador, Vista, Activo)
        VALUES (@IdMenuReportes, 'Indicadores', 'fas fa-chart-line', 'Indicadores', 'Index', 1)
        
        PRINT 'Menú "Reportes" y submenú "Indicadores" creados exitosamente'
    END
    
    -- Asignar permisos al rol de administrador (asumiendo que IdRol = 1 es administrador)
    DECLARE @IdSubMenuIndicadores INT
    SELECT @IdSubMenuIndicadores = IdSubMenu FROM SUBMENU WHERE Nombre = 'Indicadores'
    
    IF NOT EXISTS (SELECT * FROM PERMISOS WHERE IdRol = 1 AND IdSubMenu = @IdSubMenuIndicadores)
    BEGIN
        INSERT INTO PERMISOS (IdRol, IdSubMenu, Activo)
        VALUES (1, @IdSubMenuIndicadores, 1)
        
        PRINT 'Permisos asignados al rol administrador'
    END
END
ELSE
BEGIN
    PRINT 'El submenú "Indicadores" ya existe'
END
GO
