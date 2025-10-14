USE DBVENTAS_WEB
GO

-- Verificar si existe el menú de Remitos
IF NOT EXISTS (SELECT * FROM SUBMENU WHERE Nombre = 'Remitos')
BEGIN
    -- Obtener el IdMenu de Compras o crear uno nuevo
    DECLARE @IdMenuCompras INT
    SELECT @IdMenuCompras = IdMenu FROM MENU WHERE Nombre = 'Compras'
    
    IF @IdMenuCompras IS NULL
    BEGIN
        INSERT INTO MENU (Nombre, Icono) VALUES ('Compras', 'fas fa-shopping-cart')
        SET @IdMenuCompras = SCOPE_IDENTITY()
    END

    -- Insertar submenú Remitos
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Vista, Icono)
    VALUES (@IdMenuCompras, 'Remitos', 'Remito', 'Index', 'fas fa-file-invoice')

    -- Insertar submenú Facturas
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Vista, Icono)
    VALUES (@IdMenuCompras, 'Facturas', 'Factura', 'Index', 'fas fa-file-invoice-dollar')
END
GO

-- Actualizar nombre de Compras a Orden de Compra
UPDATE SUBMENU SET Nombre = 'Registrar Orden de Compra' WHERE Nombre = 'Registrar Compra'
UPDATE SUBMENU SET Nombre = 'Consultar Ordenes de Compra' WHERE Nombre = 'Consultar Compras'
GO