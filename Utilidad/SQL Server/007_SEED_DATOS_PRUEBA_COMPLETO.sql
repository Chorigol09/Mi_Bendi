USE DBVENTAS_WEB
GO

-- =============================================
-- Script: Seed de Datos de Prueba Completos
-- Descripción: Carga datos de ejemplo para probar el sistema
-- =============================================

PRINT '======================================'
PRINT 'INICIANDO CARGA DE DATOS DE PRUEBA'
PRINT '======================================'
PRINT ''

-- ============ 1. LIMPIAR DATOS EXISTENTES (CUIDADO: SOLO EN AMBIENTE DE DESARROLLO) ============
PRINT '1. Limpiando datos existentes...'

-- Deshabilitar constraints temporalmente
ALTER TABLE DETALLE_VENTA NOCHECK CONSTRAINT ALL
ALTER TABLE VENTA NOCHECK CONSTRAINT ALL
ALTER TABLE DETALLE_FACTURA NOCHECK CONSTRAINT ALL
ALTER TABLE FACTURA NOCHECK CONSTRAINT ALL
ALTER TABLE DETALLE_REMITO NOCHECK CONSTRAINT ALL
ALTER TABLE REMITO NOCHECK CONSTRAINT ALL
ALTER TABLE DETALLE_ORDEN_COMPRA NOCHECK CONSTRAINT ALL
ALTER TABLE ORDEN_COMPRA NOCHECK CONSTRAINT ALL
ALTER TABLE PRODUCTO_TIENDA NOCHECK CONSTRAINT ALL
ALTER TABLE PRODUCTO NOCHECK CONSTRAINT ALL
ALTER TABLE USUARIO NOCHECK CONSTRAINT ALL
ALTER TABLE PERMISOS NOCHECK CONSTRAINT ALL

-- Eliminar datos
DELETE FROM DETALLE_VENTA
DELETE FROM VENTA
DELETE FROM DETALLE_FACTURA
DELETE FROM FACTURA
DELETE FROM DETALLE_REMITO
DELETE FROM REMITO
DELETE FROM DETALLE_ORDEN_COMPRA
DELETE FROM ORDEN_COMPRA
DELETE FROM PRODUCTO_TIENDA
DELETE FROM PRODUCTO
DELETE FROM CLIENTE
DELETE FROM PROVEEDOR
DELETE FROM CATEGORIA
DELETE FROM USUARIO
DELETE FROM PERMISOS
DELETE FROM SUBMENU
DELETE FROM MENU
DELETE FROM TIENDA
DELETE FROM ROL

-- Resetear identities
DBCC CHECKIDENT ('DETALLE_VENTA', RESEED, 0)
DBCC CHECKIDENT ('VENTA', RESEED, 0)
DBCC CHECKIDENT ('DETALLE_FACTURA', RESEED, 0)
DBCC CHECKIDENT ('FACTURA', RESEED, 0)
DBCC CHECKIDENT ('DETALLE_REMITO', RESEED, 0)
DBCC CHECKIDENT ('REMITO', RESEED, 0)
DBCC CHECKIDENT ('DETALLE_ORDEN_COMPRA', RESEED, 0)
DBCC CHECKIDENT ('ORDEN_COMPRA', RESEED, 0)
DBCC CHECKIDENT ('PRODUCTO_TIENDA', RESEED, 0)
DBCC CHECKIDENT ('PRODUCTO', RESEED, 0)
DBCC CHECKIDENT ('CLIENTE', RESEED, 0)
DBCC CHECKIDENT ('PROVEEDOR', RESEED, 0)
DBCC CHECKIDENT ('CATEGORIA', RESEED, 0)
DBCC CHECKIDENT ('USUARIO', RESEED, 0)
DBCC CHECKIDENT ('PERMISOS', RESEED, 0)
DBCC CHECKIDENT ('SUBMENU', RESEED, 0)
DBCC CHECKIDENT ('MENU', RESEED, 0)
DBCC CHECKIDENT ('TIENDA', RESEED, 0)
DBCC CHECKIDENT ('ROL', RESEED, 0)

-- Rehabilitar constraints
ALTER TABLE DETALLE_VENTA CHECK CONSTRAINT ALL
ALTER TABLE VENTA CHECK CONSTRAINT ALL
ALTER TABLE DETALLE_FACTURA CHECK CONSTRAINT ALL
ALTER TABLE FACTURA CHECK CONSTRAINT ALL
ALTER TABLE DETALLE_REMITO CHECK CONSTRAINT ALL
ALTER TABLE REMITO CHECK CONSTRAINT ALL
ALTER TABLE DETALLE_ORDEN_COMPRA CHECK CONSTRAINT ALL
ALTER TABLE ORDEN_COMPRA CHECK CONSTRAINT ALL
ALTER TABLE PRODUCTO_TIENDA CHECK CONSTRAINT ALL
ALTER TABLE PRODUCTO CHECK CONSTRAINT ALL
ALTER TABLE USUARIO CHECK CONSTRAINT ALL
ALTER TABLE PERMISOS CHECK CONSTRAINT ALL

PRINT '   ✓ Datos limpiados'
PRINT ''

-- ============ 2. ROLES ============
PRINT '2. Insertando Roles...'
INSERT INTO ROL (Descripcion, Activo) VALUES
('Administrador', 1),
('Empleado', 1),
('Gerente', 1)
PRINT '   ✓ 3 Roles creados'
PRINT ''

-- ============ 3. TIENDAS ============
PRINT '3. Insertando Tiendas...'
INSERT INTO TIENDA (Nombre, RUC, Direccion, Telefono, Activo) VALUES
('Sucursal Centro', '20123456789', 'Av. Principal 123, Centro', '01-2345678', 1),
('Sucursal Norte', '20123456790', 'Calle Comercio 456, Zona Norte', '01-2345679', 1),
('Sucursal Sur', '20123456791', 'Jr. Los Robles 789, Zona Sur', '01-2345680', 1)
PRINT '   ✓ 3 Tiendas creadas'
PRINT ''

-- ============ 4. MENÚS ============
PRINT '4. Insertando Menús...'
INSERT INTO MENU (Nombre, Icono, Activo) VALUES
('Mantenedor', 'fas fa-tools', 1),
('Clientes', 'fas fa-user-friends', 1),
('Compras', 'fas fa-cart-arrow-down', 1),
('Ventas', 'fas fa-cash-register', 1),
('Reportes', 'far fa-clipboard', 1)
PRINT '   ✓ 5 Menús creados'
PRINT ''

-- ============ 5. SUBMENÚS ============
PRINT '5. Insertando SubMenús...'
INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Vista, Icono, Activo) VALUES
-- Mantenedor
(1, 'Roles', 'Rol', 'Crear', 'fas fa-user-shield', 1),
(1, 'Usuarios', 'Usuario', 'Crear', 'fas fa-user-cog', 1),
(1, 'Categorias', 'Categoria', 'Crear', 'fas fa-layer-group', 1),
(1, 'Productos', 'Producto', 'Crear', 'fas fa-boxes', 1),
(1, 'Asignar Productos', 'Producto', 'Asignar', 'fas fa-link', 1),
(1, 'Proveedores', 'Proveedor', 'Crear', 'fas fa-people-carry', 1),
-- Clientes
(2, 'Clientes', 'Cliente', 'Crear', 'fas fa-user-friends', 1),
-- Compras
(3, 'Registrar Orden de Compra', 'Compra', 'Crear', 'fas fa-cart-arrow-down', 1),
(3, 'Consultar Ordenes de Compra', 'Compra', 'Consultar', 'far fa-list-alt', 1),
(3, 'Remitos', 'Remito', 'Index', 'fas fa-file-invoice', 1),
(3, 'Facturas', 'Factura', 'Index', 'fas fa-file-invoice-dollar', 1),
-- Ventas
(4, 'Tiendas', 'Tienda', 'Crear', 'fas fa-store-alt', 1),
(4, 'Registrar Venta', 'Venta', 'Crear', 'fas fa-cash-register', 1),
(4, 'Consultar Venta', 'Venta', 'Consultar', 'far fa-clipboard', 1),
-- Reportes
(5, 'Productos por tienda', 'Reportes', 'Producto', 'fas fa-boxes', 1),
(5, 'Ventas', 'Reportes', 'Ventas', 'fas fa-shopping-basket', 1)
PRINT '   ✓ 17 SubMenús creados'
PRINT ''

-- ============ 6. USUARIOS ============
PRINT '6. Insertando Usuarios...'
-- Clave para todos: admin123 (ya hasheada)
INSERT INTO USUARIO (Nombres, Apellidos, Correo, Clave, IdTienda, IdRol, Activo) VALUES
('Santiago', 'Gil', 'admin@mibendi.com', 'admin123', 1, 1, 1),
('María', 'López', 'maria@mibendi.com', 'admin123', 1, 2, 1),
('Juan', 'Pérez', 'juan@mibendi.com', 'admin123', 2, 2, 1),
('Ana', 'García', 'ana@mibendi.com', 'admin123', 3, 3, 1)
PRINT '   ✓ 4 Usuarios creados (Clave: admin123)'
PRINT ''

-- ============ 7. PERMISOS (Todos para Administrador) ============
PRINT '7. Asignando Permisos...'
INSERT INTO PERMISOS (IdRol, IdSubMenu, Activo)
SELECT 1, IdSubMenu, 1 FROM SUBMENU WHERE Activo = 1
PRINT '   ✓ Permisos asignados al Administrador'
PRINT ''

-- ============ 8. CATEGORÍAS ============
PRINT '8. Insertando Categorías...'
INSERT INTO CATEGORIA (Descripcion, Activo) VALUES
('Electrónica', 1),
('Ropa', 1),
('Alimentos', 1),
('Bebidas', 1),
('Hogar', 1)
PRINT '   ✓ 5 Categorías creadas'
PRINT ''

-- ============ 9. PRODUCTOS ============
PRINT '9. Insertando Productos...'
INSERT INTO PRODUCTO (Codigo, ValorCodigo, Nombre, Descripcion, IdCategoria, PrecioVenta, Activo) VALUES
('PROD001', 1, 'Laptop HP 15', 'Laptop HP Core i5, 8GB RAM, 256GB SSD', 1, 2500.00, 1),
('PROD002', 2, 'Mouse Logitech', 'Mouse inalámbrico Logitech M280', 1, 35.00, 1),
('PROD003', 3, 'Teclado Mecánico', 'Teclado mecánico RGB retroiluminado', 1, 120.00, 1),
('PROD004', 4, 'Polo Básico', 'Polo 100% algodón manga corta', 2, 25.00, 1),
('PROD005', 5, 'Jean Levis', 'Jean Levis 501 Original Fit', 2, 150.00, 1),
('PROD006', 6, 'Arroz Costeño 1kg', 'Arroz extra Costeño bolsa 1kg', 3, 4.50, 1),
('PROD007', 7, 'Aceite Primor 1L', 'Aceite vegetal Primor 1 litro', 3, 8.90, 1),
('PROD008', 8, 'Coca Cola 3L', 'Gaseosa Coca Cola 3 litros', 4, 7.50, 1),
('PROD009', 9, 'Inca Kola 1.5L', 'Gaseosa Inca Kola 1.5 litros', 4, 5.00, 1),
('PROD010', 10, 'Sartén Teflon', 'Sartén antiadherente 28cm', 5, 45.00, 1)
PRINT '   ✓ 10 Productos creados'
PRINT ''

-- ============ 10. PRODUCTO_TIENDA ============
PRINT '10. Asignando Productos a Tiendas...'
-- Sucursal Centro - Todos los productos
INSERT INTO PRODUCTO_TIENDA (IdProducto, IdTienda, PrecioUnidadCompra, PrecioUnidadVenta, Stock, Activo, Iniciado) VALUES
(1, 1, 2000.00, 2500.00, 5, 1, 1),
(2, 1, 25.00, 35.00, 20, 1, 1),
(3, 1, 90.00, 120.00, 15, 1, 1),
(4, 1, 18.00, 25.00, 50, 1, 1),
(5, 1, 120.00, 150.00, 30, 1, 1),
(6, 1, 3.50, 4.50, 100, 1, 1),
(7, 1, 7.00, 8.90, 80, 1, 1),
(8, 1, 6.00, 7.50, 60, 1, 1),
(9, 1, 4.00, 5.00, 70, 1, 1),
(10, 1, 35.00, 45.00, 25, 1, 1),

-- Sucursal Norte - Productos selectos
(1, 2, 2000.00, 2500.00, 3, 1, 1),
(2, 2, 25.00, 35.00, 15, 1, 1),
(4, 2, 18.00, 25.00, 40, 1, 1),
(6, 2, 3.50, 4.50, 120, 1, 1),
(8, 2, 6.00, 7.50, 50, 1, 1),

-- Sucursal Sur - Productos selectos
(3, 3, 90.00, 120.00, 10, 1, 1),
(5, 3, 120.00, 150.00, 25, 1, 1),
(7, 3, 7.00, 8.90, 90, 1, 1),
(9, 3, 4.00, 5.00, 80, 1, 1),
(10, 3, 35.00, 45.00, 20, 1, 1)
PRINT '   ✓ Productos asignados a tiendas con stock inicial'
PRINT ''

-- ============ 11. PROVEEDORES ============
PRINT '11. Insertando Proveedores...'
INSERT INTO PROVEEDOR (RUC, RazonSocial, Telefono, Correo, Direccion, Activo) VALUES
('20987654321', 'TECH IMPORT S.A.C.', '01-3456789', 'ventas@techimport.com', 'Av. Tecnología 456', 1),
('20987654322', 'TEXTILES DEL PERÚ S.A.', '01-3456790', 'info@textilespe.com', 'Jr. Industrial 789', 1),
('20987654323', 'DISTRIBUIDORA ALIMENTOS SAC', '01-3456791', 'pedidos@distalimentos.com', 'Av. Mayorista 123', 1),
('20987654324', 'BEBIDAS Y MÁS EIRL', '01-3456792', 'ventas@bebidasmas.com', 'Calle Comercio 321', 1)
PRINT '   ✓ 4 Proveedores creados'
PRINT ''

-- ============ 12. ÓRDENES DE COMPRA ============
PRINT '12. Insertando Órdenes de Compra...'
SET IDENTITY_INSERT ORDEN_COMPRA ON

INSERT INTO ORDEN_COMPRA (IdCompra, IdUsuario, IdProveedor, IdTienda, TotalCosto, TipoComprobante, Estado, Activo, FechaRegistro) VALUES
(1, 1, 1, 1, 6500.00, 'Factura', 'Abierta', 1, GETDATE()-10),
(2, 1, 2, 1, 3200.00, 'Factura', 'Abierta', 1, GETDATE()-8),
(3, 1, 3, 2, 1500.00, 'Factura', 'Cerrada', 1, GETDATE()-15)

SET IDENTITY_INSERT ORDEN_COMPRA OFF
PRINT '   ✓ 3 Órdenes de Compra creadas'
PRINT ''

-- ============ 13. DETALLES DE ORDEN DE COMPRA ============
PRINT '13. Insertando Detalles de Órdenes...'
INSERT INTO DETALLE_ORDEN_COMPRA (IdOrdenCompra, IdProducto, Cantidad, PrecioUnitarioCompra, PrecioUnitarioVenta, TotalCosto, Activo) VALUES
-- OC 1 - Electrónica
(1, 1, 3, 2000.00, 0, 6000.00, 1),
(1, 2, 20, 25.00, 0, 500.00, 1),

-- OC 2 - Ropa
(2, 4, 50, 18.00, 0, 900.00, 1),
(2, 5, 20, 120.00, 0, 2400.00, 1),

-- OC 3 - Alimentos (Cerrada)
(3, 6, 100, 3.50, 0, 350.00, 1),
(3, 7, 50, 7.00, 0, 350.00, 1),
(3, 8, 60, 6.00, 0, 360.00, 1),
(3, 9, 80, 4.00, 0, 320.00, 1)
PRINT '   ✓ Detalles de órdenes insertados'
PRINT ''

-- ============ 14. REMITOS ============
PRINT '14. Insertando Remitos...'
INSERT INTO REMITO (IdOrdenCompra, IdProveedor, NumeroRemito, Estado, Observaciones, Activo, FechaRegistro, FechaRecepcion) VALUES
(1, 1, 'REM-2024-001', 'En Espera', 'Pendiente de recepción de laptops', 1, GETDATE()-9, NULL),
(2, 2, 'REM-2024-002', 'Recibido', 'Mercadería recibida completa', 1, GETDATE()-7, GETDATE()-6),
(3, 3, 'REM-2024-003', 'Recibido', 'Todo conforme', 1, GETDATE()-14, GETDATE()-13)
PRINT '   ✓ 3 Remitos creados'
PRINT ''

-- ============ 15. DETALLES DE REMITO ============
PRINT '15. Insertando Detalles de Remitos...'
INSERT INTO DETALLE_REMITO (IdRemito, IdProducto, Cantidad, Activo) VALUES
-- Remito 1
(1, 1, 3, 1),
(1, 2, 20, 1),
-- Remito 2
(2, 4, 50, 1),
(2, 5, 20, 1),
-- Remito 3
(3, 6, 100, 1),
(3, 7, 50, 1),
(3, 8, 60, 1),
(3, 9, 80, 1)
PRINT '   ✓ Detalles de remitos insertados'
PRINT ''

-- ============ 16. FACTURAS ============
PRINT '16. Insertando Facturas...'
INSERT INTO FACTURA (IdOrdenCompra, IdProveedor, NumeroFactura, Total, Estado, Observaciones, Activo, FechaEmision, FechaPago) VALUES
(1, 1, 'F001-00123', 6500.00, 'Pendiente', 'Factura pendiente de pago', 1, GETDATE()-9, NULL),
(2, 2, 'F001-00124', 3200.00, 'Pendiente', 'Pago programado para fin de mes', 1, GETDATE()-7, NULL),
(3, 3, 'F001-00125', 1500.00, 'Pagado', 'Pagado en efectivo', 1, GETDATE()-14, GETDATE()-10)
PRINT '   ✓ 3 Facturas creadas'
PRINT ''

-- ============ 17. DETALLES DE FACTURA ============
PRINT '17. Insertando Detalles de Facturas...'
INSERT INTO DETALLE_FACTURA (IdFactura, IdProducto, Cantidad, PrecioUnitario, Subtotal, Activo) VALUES
-- Factura 1
(1, 1, 3, 2000.00, 6000.00, 1),
(1, 2, 20, 25.00, 500.00, 1),
-- Factura 2
(2, 4, 50, 18.00, 900.00, 1),
(2, 5, 20, 120.00, 2400.00, 1),
-- Factura 3
(3, 6, 100, 3.50, 350.00, 1),
(3, 7, 50, 7.00, 350.00, 1),
(3, 8, 60, 6.00, 360.00, 1),
(3, 9, 80, 4.00, 320.00, 1)
PRINT '   ✓ Detalles de facturas insertados'
PRINT ''

-- ============ 18. CLIENTES ============
PRINT '18. Insertando Clientes...'
INSERT INTO CLIENTE (TipoDocumento, NumeroDocumento, Nombre, Direccion, Telefono, Activo) VALUES
('DNI', '12345678', 'Carlos Mendoza', 'Av. Los Álamos 456', '987654321', 1),
('DNI', '87654321', 'Rosa Flores', 'Jr. Las Flores 789', '987654322', 1),
('RUC', '20456789123', 'EMPRESA XYZ SAC', 'Av. Empresarial 123', '01-4567890', 1),
('DNI', '45678912', 'Pedro Sánchez', 'Calle Los Pinos 321', '987654323', 1)
PRINT '   ✓ 4 Clientes creados'
PRINT ''

-- ============ 19. VENTAS ============
PRINT '19. Insertando Ventas...'
SET IDENTITY_INSERT VENTA ON

INSERT INTO VENTA (IdVenta, Codigo, ValorCodigo, IdTienda, IdUsuario, IdCliente, TipoDocumento, CantidadProducto, CantidadTotal, TotalCosto, ImporteRecibido, ImporteCambio, Activo, FechaRegistro) VALUES
(1, 'V001-00001', 1, 1, 2, 1, 'Boleta', 2, 3, 105.00, 110.00, 5.00, 1, GETDATE()-5),
(2, 'V001-00002', 2, 1, 2, 2, 'Factura', 3, 10, 325.00, 330.00, 5.00, 1, GETDATE()-4),
(3, 'V001-00003', 3, 2, 3, 3, 'Factura', 2, 5, 142.50, 150.00, 7.50, 1, GETDATE()-3)

SET IDENTITY_INSERT VENTA OFF
PRINT '   ✓ 3 Ventas creadas'
PRINT ''

-- ============ 20. DETALLES DE VENTA ============
PRINT '20. Insertando Detalles de Ventas...'
INSERT INTO DETALLE_VENTA (IdVenta, IdProducto, Cantidad, PrecioUnidad, ImporteTotal, Activo) VALUES
-- Venta 1
(1, 2, 2, 35.00, 70.00, 1),
(1, 2, 1, 35.00, 35.00, 1),

-- Venta 2
(2, 4, 5, 25.00, 125.00, 1),
(2, 6, 10, 4.50, 45.00, 1),
(2, 8, 20, 7.50, 150.00, 1),

-- Venta 3
(3, 2, 3, 35.00, 105.00, 1),
(3, 9, 2, 5.00, 10.00, 1)
PRINT '   ✓ Detalles de ventas insertados'
PRINT ''

-- ============ RESUMEN FINAL ============
PRINT ''
PRINT '======================================'
PRINT '   RESUMEN DE DATOS CARGADOS'
PRINT '======================================'
PRINT ''
SELECT 'Roles' as Tabla, COUNT(*) as Total FROM ROL UNION ALL
SELECT 'Tiendas', COUNT(*) FROM TIENDA UNION ALL
SELECT 'Menús', COUNT(*) FROM MENU UNION ALL
SELECT 'SubMenús', COUNT(*) FROM SUBMENU UNION ALL
SELECT 'Usuarios', COUNT(*) FROM USUARIO UNION ALL
SELECT 'Permisos', COUNT(*) FROM PERMISOS UNION ALL
SELECT 'Categorías', COUNT(*) FROM CATEGORIA UNION ALL
SELECT 'Productos', COUNT(*) FROM PRODUCTO UNION ALL
SELECT 'Producto-Tienda', COUNT(*) FROM PRODUCTO_TIENDA UNION ALL
SELECT 'Proveedores', COUNT(*) FROM PROVEEDOR UNION ALL
SELECT 'Órdenes Compra', COUNT(*) FROM ORDEN_COMPRA UNION ALL
SELECT 'Detalles OC', COUNT(*) FROM DETALLE_ORDEN_COMPRA UNION ALL
SELECT 'Remitos', COUNT(*) FROM REMITO UNION ALL
SELECT 'Detalles Remito', COUNT(*) FROM DETALLE_REMITO UNION ALL
SELECT 'Facturas', COUNT(*) FROM FACTURA UNION ALL
SELECT 'Detalles Factura', COUNT(*) FROM DETALLE_FACTURA UNION ALL
SELECT 'Clientes', COUNT(*) FROM CLIENTE UNION ALL
SELECT 'Ventas', COUNT(*) FROM VENTA UNION ALL
SELECT 'Detalles Venta', COUNT(*) FROM DETALLE_VENTA

PRINT ''
PRINT '======================================'
PRINT '   ✓ CARGA COMPLETADA EXITOSAMENTE'
PRINT '======================================'
PRINT ''
PRINT 'CREDENCIALES DE ACCESO:'
PRINT 'Usuario: admin@mibendi.com'
PRINT 'Clave: admin123'
PRINT ''
GO
