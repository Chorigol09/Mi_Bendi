USE DBVENTAS_WEB
GO

-- =============================================
-- Script: Mejoras Sistema - Orden de Compra, Remitos y Facturas
-- Descripción: Renombra Compra a Orden de Compra y agrega nuevas tablas
-- =============================================

-- 1. Renombrar tabla COMPRA a ORDEN_COMPRA y agregar campo Estado
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'COMPRA')
BEGIN
    -- Renombrar tabla
    EXEC sp_rename 'COMPRA', 'ORDEN_COMPRA';
    
    -- Agregar campo Estado si no existe
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ORDEN_COMPRA' AND COLUMN_NAME = 'Estado')
    BEGIN
        ALTER TABLE ORDEN_COMPRA ADD Estado varchar(20) DEFAULT 'Abierta' NOT NULL;
    END
END
GO

-- 2. Renombrar tabla DETALLE_COMPRA a DETALLE_ORDEN_COMPRA
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DETALLE_COMPRA')
BEGIN
    EXEC sp_rename 'DETALLE_COMPRA', 'DETALLE_ORDEN_COMPRA';
    
    -- Actualizar nombre de columna IdCompra a IdOrdenCompra
    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DETALLE_ORDEN_COMPRA' AND COLUMN_NAME = 'IdCompra')
    BEGIN
        EXEC sp_rename 'DETALLE_ORDEN_COMPRA.IdCompra', 'IdOrdenCompra', 'COLUMN';
    END
END
GO

-- 3. Crear tabla REMITO
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'REMITO')
CREATE TABLE REMITO(
    IdRemito int primary key identity(1,1),
    IdOrdenCompra int references ORDEN_COMPRA(IdCompra),
    IdProveedor int references PROVEEDOR(IdProveedor),
    NumeroRemito varchar(50),
    Estado varchar(20) DEFAULT 'En Espera' NOT NULL, -- 'En Espera' o 'Recibido'
    Observaciones varchar(500),
    Activo bit default 1,
    FechaRegistro datetime default getdate(),
    FechaRecepcion datetime NULL
)
GO

-- 4. Crear tabla DETALLE_REMITO
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DETALLE_REMITO')
CREATE TABLE DETALLE_REMITO(
    IdDetalleRemito int primary key identity(1,1),
    IdRemito int references REMITO(IdRemito),
    IdProducto int references PRODUCTO(IdProducto),
    Cantidad int NOT NULL,
    Activo bit default 1,
    FechaRegistro datetime default getdate()
)
GO

-- 5. Crear tabla FACTURA
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'FACTURA')
CREATE TABLE FACTURA(
    IdFactura int primary key identity(1,1),
    IdOrdenCompra int references ORDEN_COMPRA(IdCompra),
    IdProveedor int references PROVEEDOR(IdProveedor),
    NumeroFactura varchar(50),
    Total decimal(18,2) NOT NULL DEFAULT 0,
    Estado varchar(20) DEFAULT 'Pendiente' NOT NULL, -- 'Pendiente' o 'Pagado'
    Observaciones varchar(500),
    Activo bit default 1,
    FechaEmision datetime default getdate(),
    FechaPago datetime NULL
)
GO

-- 6. Crear tabla DETALLE_FACTURA
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DETALLE_FACTURA')
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
GO

-- 7. Agregar columna PrecioVenta a PRODUCTO si no existe
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PRODUCTO' AND COLUMN_NAME = 'PrecioVenta')
BEGIN
    ALTER TABLE PRODUCTO ADD PrecioVenta decimal(18,2) DEFAULT 0;
END
GO

PRINT 'Script ejecutado correctamente. Tablas ORDEN_COMPRA, REMITO y FACTURA creadas/actualizadas.'
GO
