USE DBVENTAS_WEB
GO

-- Verificar si ya existen los menús
IF NOT EXISTS (SELECT 1 FROM MENU WHERE Nombre = 'Registrar Orden Pago')
BEGIN
    -- Insertar menú principal si no existe
    IF NOT EXISTS (SELECT 1 FROM MENU WHERE Nombre = 'Órdenes de Pago')
    BEGIN
        INSERT INTO MENU (Nombre, Icono, Activo, FechaRegistro)
        VALUES ('Órdenes de Pago', 'dollar-sign', 1, GETDATE())
    END

    -- Obtener el ID del menú padre
    DECLARE @IdMenuPadre INT = (SELECT IdMenu FROM MENU WHERE Nombre = 'Órdenes de Pago')

    -- Insertar submenús
    INSERT INTO MENU (Nombre, Icono, Activo, FechaRegistro)
    VALUES 
        ('Registrar Orden Pago', 'plus-circle', 1, GETDATE()),
        ('Consultar Orden Pago', 'list', 1, GETDATE())
    
    -- Obtener IDs de los nuevos menús
    DECLARE @IdRegistrar INT = SCOPE_IDENTITY() - 1
    DECLARE @IdConsultar INT = SCOPE_IDENTITY()

    -- Insertar en MENU_ROL (asumiendo que el rol Administrador tiene ID = 1)
    IF NOT EXISTS (SELECT 1 FROM MENU_ROL WHERE IdMenu = @IdMenuPadre AND IdRol = 1)
    BEGIN
        INSERT INTO MENU_ROL (IdMenu, IdRol, FechaRegistro)
        VALUES 
            (@IdMenuPadre, 1, GETDATE()),
            (@IdRegistrar, 1, GETDATE()),
            (@IdConsultar, 1, GETDATE())
    END

    PRINT '✓ Menús de Órdenes de Pago agregados correctamente'
END
ELSE
BEGIN
    PRINT '✓ Los menús de Órdenes de Pago ya existen'
END
GO