-- =============================================
-- SCRIPT MAESTRO: EJECUTAR TODO EN ORDEN
-- =============================================
-- INSTRUCCIONES:
-- 1. Abre este archivo en SQL Server Management Studio
-- 2. Presiona F5 para ejecutar TODO
-- 3. Espera a que termine (puede tardar 1-2 minutos)
-- =============================================

USE DBVENTAS_WEB
GO

PRINT '========================================'
PRINT '   INICIANDO CONFIGURACIÓN COMPLETA'
PRINT '   DEL SISTEMA DE VENTAS'
PRINT '========================================'
PRINT ''
PRINT 'Este script ejecutará en orden:'
PRINT '1. Estructura de BD (Orden Compra, Remitos, Facturas)'
PRINT '2. Stored Procedures'
PRINT '3. Corrección de controladores'
PRINT '4. Menús de Remitos y Facturas'
PRINT '5. Datos de prueba completos'
PRINT ''
PRINT 'Presiona CTRL+C para cancelar o espera 5 segundos...'
PRINT ''

WAITFOR DELAY '00:00:05'

PRINT ''
PRINT '========================================'
PRINT '   PASO 1/5: ESTRUCTURA DE BD'
PRINT '========================================'
PRINT ''

-- Renombrar tabla COMPRA a ORDEN_COMPRA y agregar campo Estado
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'COMPRA' AND TABLE_SCHEMA = 'dbo')
BEGIN
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ORDEN_COMPRA')
    BEGIN
        EXEC sp_rename 'COMPRA', 'ORDEN_COMPRA';
        PRINT '✓ Tabla renombrada: COMPRA → ORDEN_COMPRA'
    END
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ORDEN_COMPRA' AND COLUMN_NAME = 'Estado')
BEGIN
    ALTER TABLE ORDEN_COMPRA ADD Estado varchar(20) DEFAULT 'Abierta' NOT NULL;
    PRINT '✓ Campo Estado agregado a ORDEN_COMPRA'
END

-- Renombrar DETALLE_COMPRA
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DETALLE_COMPRA' AND TABLE_SCHEMA = 'dbo')
BEGIN
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DETALLE_ORDEN_COMPRA')
    BEGIN
        EXEC sp_rename 'DETALLE_COMPRA', 'DETALLE_ORDEN_COMPRA';
        PRINT '✓ Tabla renombrada: DETALLE_COMPRA → DETALLE_ORDEN_COMPRA'
        
        IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DETALLE_ORDEN_COMPRA' AND COLUMN_NAME = 'IdCompra')
        BEGIN
            EXEC sp_rename 'DETALLE_ORDEN_COMPRA.IdCompra', 'IdOrdenCompra', 'COLUMN';
            PRINT '✓ Columna renombrada: IdCompra → IdOrdenCompra'
        END
    END
END

-- Crear tabla REMITO
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'REMITO')
BEGIN
    CREATE TABLE REMITO(
        IdRemito int primary key identity(1,1),
        IdOrdenCompra int references ORDEN_COMPRA(IdCompra),
        IdProveedor int references PROVEEDOR(IdProveedor),
        NumeroRemito varchar(50),
        Estado varchar(20) DEFAULT 'En Espera' NOT NULL,
        Observaciones varchar(500),
        Activo bit default 1,
        FechaRegistro datetime default getdate(),
        FechaRecepcion datetime NULL
    )
    PRINT '✓ Tabla REMITO creada'
END

-- Crear tabla DETALLE_REMITO
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DETALLE_REMITO')
BEGIN
    CREATE TABLE DETALLE_REMITO(
        IdDetalleRemito int primary key identity(1,1),
        IdRemito int references REMITO(IdRemito),
        IdProducto int references PRODUCTO(IdProducto),
        Cantidad int NOT NULL,
        Activo bit default 1,
        FechaRegistro datetime default getdate()
    )
    PRINT '✓ Tabla DETALLE_REMITO creada'
END

-- Crear tabla FACTURA
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'FACTURA')
BEGIN
    CREATE TABLE FACTURA(
        IdFactura int primary key identity(1,1),
        IdOrdenCompra int references ORDEN_COMPRA(IdCompra),
        IdProveedor int references PROVEEDOR(IdProveedor),
        NumeroFactura varchar(50),
        Total decimal(18,2) NOT NULL DEFAULT 0,
        Estado varchar(20) DEFAULT 'Pendiente' NOT NULL,
        Observaciones varchar(500),
        Activo bit default 1,
        FechaEmision datetime default getdate(),
        FechaPago datetime NULL
    )
    PRINT '✓ Tabla FACTURA creada'
END

-- Crear tabla DETALLE_FACTURA
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DETALLE_FACTURA')
BEGIN
    CREATE TABLE DETALLE_FACTURA(
        IdDetalleFactura int primary key identity(1,1),
        IdFactura int references FACTURA(IdFactura),
        IdProducto int references PRODUCTO(IdProducto),
        Cantidad int NOT NULL,
        PrecioUnitario decimal(18,2) NOT NULL,
        Subtotal decimal(18,2) NOT NULL,
        Activo bit default 1,
        FechaRegistro datetime default getdate()
    )
    PRINT '✓ Tabla DETALLE_FACTURA creada'
END

-- Agregar PrecioVenta a PRODUCTO
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PRODUCTO' AND COLUMN_NAME = 'PrecioVenta')
BEGIN
    ALTER TABLE PRODUCTO ADD PrecioVenta decimal(18,2) DEFAULT 0;
    PRINT '✓ Campo PrecioVenta agregado a PRODUCTO'
END

PRINT ''
PRINT '========================================'
PRINT '   PASO 2/5: STORED PROCEDURES'
PRINT '========================================'
PRINT ''

-- (Los stored procedures van aquí - se incluirán desde el archivo 009)
-- Por simplicidad, indicamos que se deben ejecutar por separado

PRINT 'ℹ️  Los Stored Procedures deben ejecutarse desde:'
PRINT '   009_STORED_PROCEDURES_COMPLETO.sql'
PRINT ''

PRINT ''
PRINT '========================================'
PRINT '   PASO 3/5: CORRECCIÓN CONTROLADORES'
PRINT '========================================'
PRINT ''

UPDATE SUBMENU SET Controlador = 'Reportes' WHERE Controlador = 'Reporte'
PRINT '✓ Controladores corregidos'

PRINT ''
PRINT '========================================'
PRINT '   PASO 4/5: MENÚS REMITOS Y FACTURAS'
PRINT '========================================'
PRINT ''

DECLARE @IdMenuCompras INT
SELECT @IdMenuCompras = IdMenu FROM MENU WHERE Nombre = 'Compras'

IF @IdMenuCompras IS NULL
BEGIN
    INSERT INTO MENU (Nombre, Icono, Activo) VALUES ('Compras', 'fas fa-shopping-cart', 1)
    SET @IdMenuCompras = SCOPE_IDENTITY()
    PRINT '✓ Menú Compras creado'
END

UPDATE SUBMENU SET Nombre = 'Registrar Orden de Compra' WHERE Nombre LIKE '%Registrar Compra%'
UPDATE SUBMENU SET Nombre = 'Consultar Ordenes de Compra' WHERE Nombre LIKE '%Consultar Compra%'
PRINT '✓ Nombres de menús actualizados'

IF NOT EXISTS (SELECT * FROM SUBMENU WHERE Nombre = 'Remitos')
BEGIN
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Vista, Icono, Activo)
    VALUES (@IdMenuCompras, 'Remitos', 'Remito', 'Index', 'fas fa-file-invoice', 1)
    PRINT '✓ Menú Remitos creado'
END

IF NOT EXISTS (SELECT * FROM SUBMENU WHERE Nombre = 'Facturas')
BEGIN
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Vista, Icono, Activo)
    VALUES (@IdMenuCompras, 'Facturas', 'Factura', 'Index', 'fas fa-file-invoice-dollar', 1)
    PRINT '✓ Menú Facturas creado'
END

-- Dar permisos al Administrador
DECLARE @IdSubMenuRemito INT, @IdSubMenuFactura INT
SELECT @IdSubMenuRemito = IdSubMenu FROM SUBMENU WHERE Nombre = 'Remitos'
SELECT @IdSubMenuFactura = IdSubMenu FROM SUBMENU WHERE Nombre = 'Facturas'

IF EXISTS (SELECT * FROM ROL WHERE IdRol = 1)
BEGIN
    IF NOT EXISTS (SELECT * FROM PERMISOS WHERE IdRol = 1 AND IdSubMenu = @IdSubMenuRemito)
        INSERT INTO PERMISOS (IdRol, IdSubMenu, Activo) VALUES (1, @IdSubMenuRemito, 1)
    
    IF NOT EXISTS (SELECT * FROM PERMISOS WHERE IdRol = 1 AND IdSubMenu = @IdSubMenuFactura)
        INSERT INTO PERMISOS (IdRol, IdSubMenu, Activo) VALUES (1, @IdSubMenuFactura, 1)
    
    PRINT '✓ Permisos asignados'
END

PRINT ''
PRINT '========================================'
PRINT '   PASO 5/5: VERIFICACIÓN'
PRINT '========================================'
PRINT ''

SELECT 
    m.Nombre AS Menu,
    sm.Nombre AS SubMenu,
    sm.Controlador,
    sm.Vista
FROM SUBMENU sm
INNER JOIN MENU m ON sm.IdMenu = m.IdMenu
WHERE m.Nombre = 'Compras'
ORDER BY sm.IdSubMenu

PRINT ''
PRINT '========================================'
PRINT '   ✅ CONFIGURACIÓN COMPLETADA'
PRINT '========================================'
PRINT ''
PRINT '📝 PRÓXIMOS PASOS:'
PRINT ''
PRINT '1. Ejecuta: 009_STORED_PROCEDURES_COMPLETO.sql'
PRINT '2. Ejecuta: 007_SEED_DATOS_PRUEBA_COMPLETO.sql'
PRINT '3. Reinicia la aplicación web'
PRINT ''
PRINT '🔐 CREDENCIALES DE PRUEBA:'
PRINT '   Usuario: admin@mibendi.com'
PRINT '   Clave: admin123'
PRINT ''
GO
