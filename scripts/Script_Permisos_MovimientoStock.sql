USE [DBVENTAS_WEB]
GO

-- =============================================
-- Asignar Permisos para Movimiento Stock
-- =============================================

-- Obtener el IdSubMenu de Movimiento Stock
DECLARE @IdSubMenu INT
SELECT @IdSubMenu = IdSubMenu FROM SUBMENU WHERE Nombre = 'Movimiento Stock'

PRINT 'IdSubMenu de Movimiento Stock: ' + CAST(@IdSubMenu AS VARCHAR(10))

-- Ver qué columnas tiene la tabla PERMISOS
PRINT ''
PRINT 'Columnas de PERMISOS:'
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PERMISOS'
GO

-- Asignar permiso al rol Administrador (IdRol = 1, ajusta si es diferente)
DECLARE @IdSubMenu INT
SELECT @IdSubMenu = IdSubMenu FROM SUBMENU WHERE Nombre = 'Movimiento Stock'

-- Verificar si ya existe el permiso
IF NOT EXISTS (SELECT 1 FROM PERMISOS WHERE IdRol = 1 AND IdSubMenu = @IdSubMenu)
BEGIN
    INSERT INTO PERMISOS (IdRol, IdSubMenu, Activo, FechaRegistro)
    VALUES (1, @IdSubMenu, 1, GETDATE())
    
    PRINT ''
    PRINT 'Permiso asignado al rol Administrador (IdRol=1)'
END
ELSE
BEGIN
    PRINT ''
    PRINT 'El permiso ya existe para el rol Administrador'
END
GO

-- Mostrar todos los roles disponibles
PRINT ''
PRINT 'Roles disponibles:'
SELECT IdRol, Descripcion FROM ROL WHERE Activo = 1
GO

-- Mostrar permisos asignados para Movimiento Stock
PRINT ''
PRINT 'Permisos asignados para Movimiento Stock:'
SELECT 
    r.IdRol,
    r.Descripcion AS Rol,
    s.Nombre AS SubMenu,
    p.Activo
FROM PERMISOS p
INNER JOIN ROL r ON p.IdRol = r.IdRol
INNER JOIN SUBMENU s ON p.IdSubMenu = s.IdSubMenu
WHERE s.Nombre = 'Movimiento Stock'
GO

PRINT ''
PRINT '===================================='
PRINT '✓ Permisos configurados!'
PRINT '===================================='
PRINT 'Cierra sesión y vuelve a ingresar'
PRINT 'para ver el menú Movimiento Stock'
PRINT '===================================='
GO
