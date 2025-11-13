-- =============================================
-- SCRIPT: AGREGAR MENÚ DE LISTAS DE PRECIOS
-- Fecha: 2025-11-12
-- Descripción: Agrega opciones de menú para el sistema de listas de precios
-- =============================================

USE DBVENTAS_WEB
GO

PRINT '====================================='
PRINT 'AGREGANDO MENÚ LISTAS DE PRECIOS'
PRINT '====================================='

DECLARE @IdMenu INT
DECLARE @IdSubMenu INT
DECLARE @IdRolAdmin INT

-- =============================================
-- PASO 1: Verificar o crear menú "Administración"
-- =============================================
IF NOT EXISTS (SELECT 1 FROM MENU WHERE Nombre = 'Administracion')
BEGIN
    INSERT INTO MENU (Nombre, Icono, Activo) 
    VALUES ('Administracion', 'fa fa-cogs', 1)
    PRINT 'Menú "Administración" creado'
END
ELSE
BEGIN
    PRINT 'Menú "Administración" ya existe'
END

SELECT @IdMenu = IdMenu FROM MENU WHERE Nombre = 'Administracion'
PRINT 'IdMenu Administración: ' + CAST(@IdMenu AS VARCHAR)

-- =============================================
-- PASO 2: Agregar submenú "Listas de Precios"
-- =============================================
IF NOT EXISTS (SELECT 1 FROM SUBMENU WHERE Nombre = 'Listas de Precios')
BEGIN
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Vista, Icono, Activo)
    VALUES (@IdMenu, 'Listas de Precios', 'ListaPrecio', 'Index', 'fa fa-list-alt', 1)
    
    PRINT 'Submenú "Listas de Precios" creado exitosamente'
END
ELSE
BEGIN
    PRINT 'Submenú "Listas de Precios" ya existe'
    
    -- Actualizar por si cambió algo
    UPDATE SUBMENU 
    SET IdMenu = @IdMenu,
        Controlador = 'ListaPrecio',
        Vista = 'Index',
        Icono = 'fa fa-list-alt',
        Activo = 1
    WHERE Nombre = 'Listas de Precios'
    
    PRINT 'Submenú actualizado'
END

SELECT @IdSubMenu = IdSubMenu FROM SUBMENU WHERE Nombre = 'Listas de Precios'
PRINT 'IdSubMenu creado: ' + CAST(@IdSubMenu AS VARCHAR)

-- =============================================
-- PASO 3: Asignar permisos al rol Administrador
-- =============================================
-- Buscar el rol de administrador (puede variar el nombre)
SELECT @IdRolAdmin = IdRol 
FROM ROL 
WHERE Descripcion IN ('Administrador', 'ADMINISTRADOR', 'Admin')
ORDER BY IdRol
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY

IF @IdRolAdmin IS NOT NULL
BEGIN
    -- Verificar si ya existe el permiso
    IF NOT EXISTS (SELECT 1 FROM PERMISOS WHERE IdRol = @IdRolAdmin AND IdSubMenu = @IdSubMenu)
    BEGIN
        INSERT INTO PERMISOS (IdRol, IdSubMenu, Activo)
        VALUES (@IdRolAdmin, @IdSubMenu, 1)
        
        PRINT 'Permiso asignado al rol de Administrador (IdRol: ' + CAST(@IdRolAdmin AS VARCHAR) + ')'
    END
    ELSE
    BEGIN
        -- Asegurarse de que esté activo
        UPDATE PERMISOS 
        SET Activo = 1 
        WHERE IdRol = @IdRolAdmin AND IdSubMenu = @IdSubMenu
        
        PRINT 'Permiso ya existe y fue actualizado a Activo'
    END
END
ELSE
BEGIN
    PRINT 'ADVERTENCIA: No se encontró rol de Administrador'
    PRINT 'Por favor, asigne los permisos manualmente'
END

-- =============================================
-- VERIFICACIÓN FINAL
-- =============================================
PRINT ''
PRINT '====================================='
PRINT 'VERIFICACIÓN DE CONFIGURACIÓN'
PRINT '====================================='

-- Verificar menú
SELECT 'MENU' AS Tabla, IdMenu, Nombre, Icono, Activo 
FROM MENU 
WHERE Nombre = 'Administracion'

-- Verificar submenú
SELECT 'SUBMENU' AS Tabla, s.IdSubMenu, s.Nombre, s.Controlador, s.Vista, s.Icono, s.Activo, m.Nombre AS Menu
FROM SUBMENU s
INNER JOIN MENU m ON s.IdMenu = m.IdMenu
WHERE s.Nombre = 'Listas de Precios'

-- Verificar permisos
SELECT 'PERMISOS' AS Tabla, p.IdPermisos, r.Descripcion AS Rol, s.Nombre AS SubMenu, p.Activo
FROM PERMISOS p
INNER JOIN ROL r ON p.IdRol = r.IdRol
INNER JOIN SUBMENU s ON p.IdSubMenu = s.IdSubMenu
WHERE s.Nombre = 'Listas de Precios'

PRINT ''
PRINT '====================================='
PRINT 'PROCESO COMPLETADO EXITOSAMENTE'
PRINT '====================================='
PRINT 'El menú "Listas de Precios" está disponible en: Administración > Listas de Precios'
PRINT ''

GO
