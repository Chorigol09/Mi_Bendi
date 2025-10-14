USE DBVENTAS_WEB
GO

-- =============================================
-- Script: Agregar Menús de Remito y Factura al TopBar
-- =============================================

-- 1. Obtener o crear el menú "Compras"
DECLARE @IdMenuCompras INT

SELECT @IdMenuCompras = IdMenu FROM MENU WHERE Nombre = 'Compras'

IF @IdMenuCompras IS NULL
BEGIN
    INSERT INTO MENU (Nombre, Icono, Activo) 
    VALUES ('Compras', 'fas fa-shopping-cart', 1)
    SET @IdMenuCompras = SCOPE_IDENTITY()
    PRINT 'Menú Compras creado con ID: ' + CAST(@IdMenuCompras AS VARCHAR)
END
ELSE
BEGIN
    PRINT 'Menú Compras ya existe con ID: ' + CAST(@IdMenuCompras AS VARCHAR)
END

-- 2. Actualizar nombres de submenús existentes (si existen)
UPDATE SUBMENU 
SET Nombre = 'Registrar Orden de Compra' 
WHERE Nombre LIKE '%Registrar Compra%' OR Nombre = 'Compra'

UPDATE SUBMENU 
SET Nombre = 'Consultar Ordenes de Compra' 
WHERE Nombre LIKE '%Consultar Compra%'

PRINT 'Nombres de menús de compras actualizados'

-- 3. Insertar submenú Remitos (si no existe)
IF NOT EXISTS (SELECT * FROM SUBMENU WHERE Nombre = 'Remitos')
BEGIN
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Vista, Icono, Activo)
    VALUES (@IdMenuCompras, 'Remitos', 'Remito', 'Index', 'fas fa-file-invoice', 1)
    PRINT 'Submenú Remitos creado'
END
ELSE
BEGIN
    PRINT 'Submenú Remitos ya existe'
END

-- 4. Insertar submenú Facturas (si no existe)
IF NOT EXISTS (SELECT * FROM SUBMENU WHERE Nombre = 'Facturas')
BEGIN
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Vista, Icono, Activo)
    VALUES (@IdMenuCompras, 'Facturas', 'Factura', 'Index', 'fas fa-file-invoice-dollar', 1)
    PRINT 'Submenú Facturas creado'
END
ELSE
BEGIN
    PRINT 'Submenú Facturas ya existe'
END

-- 5. Dar permisos al rol Administrador (IdRol = 1)
-- Obtener los IDs de los submenús recién creados
DECLARE @IdSubMenuRemito INT, @IdSubMenuFactura INT

SELECT @IdSubMenuRemito = IdSubMenu FROM SUBMENU WHERE Nombre = 'Remitos'
SELECT @IdSubMenuFactura = IdSubMenu FROM SUBMENU WHERE Nombre = 'Facturas'

-- Verificar si existe el rol Administrador
IF EXISTS (SELECT * FROM ROL WHERE IdRol = 1)
BEGIN
    -- Dar permiso de Remitos al administrador
    IF NOT EXISTS (SELECT * FROM PERMISOS WHERE IdRol = 1 AND IdSubMenu = @IdSubMenuRemito)
    BEGIN
        INSERT INTO PERMISOS (IdRol, IdSubMenu, Activo)
        VALUES (1, @IdSubMenuRemito, 1)
        PRINT 'Permiso de Remitos agregado al Administrador'
    END

    -- Dar permiso de Facturas al administrador
    IF NOT EXISTS (SELECT * FROM PERMISOS WHERE IdRol = 1 AND IdSubMenu = @IdSubMenuFactura)
    BEGIN
        INSERT INTO PERMISOS (IdRol, IdSubMenu, Activo)
        VALUES (1, @IdSubMenuFactura, 1)
        PRINT 'Permiso de Facturas agregado al Administrador'
    END
END

-- 6. Verificar resultado final
SELECT 
    m.Nombre AS Menu,
    sm.Nombre AS SubMenu,
    sm.Controlador,
    sm.Vista,
    sm.Icono,
    sm.Activo
FROM SUBMENU sm
INNER JOIN MENU m ON sm.IdMenu = m.IdMenu
WHERE m.Nombre = 'Compras'
ORDER BY sm.IdSubMenu

PRINT '✓ Script completado exitosamente'
GO
