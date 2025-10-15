USE DBVENTAS_WEB
GO

-- =============================================
-- Script: Actualizacion de Productos a Articulos de Bebe
-- Descripcion: Reemplaza productos existentes por productos de bebe organizados por categorias
-- =============================================

PRINT '======================================'
PRINT 'ACTUALIZANDO A PRODUCTOS DE BEBE'
PRINT '======================================'
PRINT ''

-- ============ 1. LIMPIAR PRODUCTOS EXISTENTES ============
PRINT '1. Limpiando productos existentes...'

-- Deshabilitar constraints temporalmente
ALTER TABLE DETALLE_VENTA NOCHECK CONSTRAINT ALL
ALTER TABLE DETALLE_FACTURA NOCHECK CONSTRAINT ALL
ALTER TABLE DETALLE_REMITO NOCHECK CONSTRAINT ALL
ALTER TABLE DETALLE_ORDEN_COMPRA NOCHECK CONSTRAINT ALL
ALTER TABLE PRODUCTO_TIENDA NOCHECK CONSTRAINT ALL
ALTER TABLE PRODUCTO NOCHECK CONSTRAINT ALL

-- Eliminar datos relacionados
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
DELETE FROM CATEGORIA

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
DBCC CHECKIDENT ('CATEGORIA', RESEED, 0)

-- Rehabilitar constraints
ALTER TABLE DETALLE_VENTA CHECK CONSTRAINT ALL
ALTER TABLE DETALLE_FACTURA CHECK CONSTRAINT ALL
ALTER TABLE DETALLE_REMITO CHECK CONSTRAINT ALL
ALTER TABLE DETALLE_ORDEN_COMPRA CHECK CONSTRAINT ALL
ALTER TABLE PRODUCTO_TIENDA CHECK CONSTRAINT ALL
ALTER TABLE PRODUCTO CHECK CONSTRAINT ALL

PRINT '   Productos anteriores eliminados'
PRINT ''

-- ============ 2. CATEGORIAS DE PRODUCTOS DE BEBE ============
PRINT '2. Insertando Categorias de Productos de Bebe...'
INSERT INTO CATEGORIA (Descripcion, Activo) VALUES
('Ropa y accesorios', 1),
('Alimentacion', 1),
('Higiene y cuidado', 1),
('Descanso y confort', 1),
('Paseo y movilidad', 1),
('Juguetes y estimulacion', 1)
PRINT '   6 Categorias creadas'
PRINT ''

-- ============ 3. PRODUCTOS DE BEBE ============
PRINT '3. Insertando Productos de Bebe...'
INSERT INTO PRODUCTO (Codigo, ValorCodigo, Nombre, Descripcion, IdCategoria, PrecioVenta, Activo) VALUES
-- Ropa y accesorios (IdCategoria = 1)
('BEBE001', 1, 'Body de algodon', 'Body 100% algodon suave para bebe', 1, 25.00, 1),
('BEBE002', 2, 'Conjunto pantalon + remera', 'Conjunto de 2 piezas para bebe', 1, 45.00, 1),
('BEBE003', 3, 'Baberos', 'Pack de 3 baberos de tela', 1, 18.00, 1),
('BEBE004', 4, 'Gorro de bebe', 'Gorro suave de algodon', 1, 12.00, 1),
('BEBE005', 5, 'Guantes y escarpines', 'Set de guantes y escarpines', 1, 15.00, 1),
('BEBE006', 6, 'Pijama enterito', 'Pijama enterito con pies', 1, 38.00, 1),
('BEBE007', 7, 'Medias antideslizantes', 'Pack de 3 pares de medias', 1, 20.00, 1),
('BEBE008', 8, 'Camperita o saquito', 'Camperita abrigada para bebe', 1, 55.00, 1),
('BEBE009', 9, 'Ranita con pie', 'Pantaloncito ranita con pie', 1, 32.00, 1),
('BEBE010', 10, 'Chaleco de lana o plush', 'Chaleco tejido suave', 1, 48.00, 1),

-- Alimentacion (IdCategoria = 2)
('BEBE011', 11, 'Mamaderas', 'Mamadera anticolicos 250ml', 2, 35.00, 1),
('BEBE012', 12, 'Tetinas de repuesto', 'Pack de 2 tetinas silicona', 2, 15.00, 1),
('BEBE013', 13, 'Chupetes', 'Pack de 2 chupetes ortodonticos', 2, 18.00, 1),
('BEBE014', 14, 'Esterilizador de mamaderas', 'Esterilizador electrico', 2, 120.00, 1),
('BEBE015', 15, 'Calienta mamaderas', 'Calienta mamaderas digital', 2, 85.00, 1),
('BEBE016', 16, 'Vajilla infantil', 'Set de plato, taza y cubiertos', 2, 42.00, 1),
('BEBE017', 17, 'Babero impermeable', 'Babero silicona con bolsillo', 2, 22.00, 1),
('BEBE018', 18, 'Silla de comer', 'Silla alta plegable para bebe', 2, 180.00, 1),
('BEBE019', 19, 'Termo para leche o agua', 'Termo termico 500ml', 2, 38.00, 1),
('BEBE020', 20, 'Contenedor para papillas', 'Set de 4 contenedores hermeticos', 2, 28.00, 1),

-- Higiene y cuidado (IdCategoria = 3)
('BEBE021', 21, 'Panales descartables', 'Paquete de panales hipoalergenicos', 3, 45.00, 1),
('BEBE022', 22, 'Toallitas humedas', 'Pack de toallitas sin alcohol', 3, 12.00, 1),
('BEBE023', 23, 'Crema para paspaduras', 'Crema protectora de oxido de zinc', 3, 25.00, 1),
('BEBE024', 24, 'Shampoo y jabon hipoalergenico', 'Set de shampoo y jabon suave', 3, 32.00, 1),
('BEBE025', 25, 'Aceite y colonia para bebe', 'Set de aceite y colonia', 3, 28.00, 1),
('BEBE026', 26, 'Cepillo y peine suave', 'Set de cepillo y peine', 3, 15.00, 1),
('BEBE027', 27, 'Termometro digital', 'Termometro digital infrarrojo', 3, 55.00, 1),
('BEBE028', 28, 'Cortaunas infantil', 'Set de manicura para bebe', 3, 18.00, 1),
('BEBE029', 29, 'Esponjas naturales', 'Pack de 2 esponjas suaves', 3, 12.00, 1),
('BEBE030', 30, 'Toalla con capucha', 'Toalla de algodon con capucha', 3, 35.00, 1),

-- Descanso y confort (IdCategoria = 4)
('BEBE031', 31, 'Cuna o moises', 'Cuna de madera con colchon', 4, 450.00, 1),
('BEBE032', 32, 'Colchon y sabanas', 'Set de colchon y sabanas', 4, 120.00, 1),
('BEBE033', 33, 'Mantas y mantitas', 'Manta suave de polar', 4, 38.00, 1),
('BEBE034', 34, 'Almohadita antirreflujo', 'Almohada inclinada para bebe', 4, 45.00, 1),
('BEBE035', 35, 'Sabanas ajustables', 'Juego de 2 sabanas ajustables', 4, 32.00, 1),
('BEBE036', 36, 'Movil musical', 'Movil con musica y luces', 4, 65.00, 1),
('BEBE037', 37, 'Luz nocturna', 'Lampara nocturna con sensor', 4, 28.00, 1),
('BEBE038', 38, 'Chichonera', 'Protector acolchado para cuna', 4, 55.00, 1),
('BEBE039', 39, 'Bolsa de dormir', 'Saco de dormir para bebe', 4, 48.00, 1),
('BEBE040', 40, 'Almohada para lactancia', 'Almohada ergonomica de lactancia', 4, 75.00, 1),

-- Paseo y movilidad (IdCategoria = 5)
('BEBE041', 41, 'Cochecito de paseo', 'Cochecito plegable con capota', 5, 850.00, 1),
('BEBE042', 42, 'Huevito para auto', 'Butaca de seguridad para auto', 5, 650.00, 1),
('BEBE043', 43, 'Portabebe ergonomico', 'Mochila portabebe ajustable', 5, 180.00, 1),
('BEBE044', 44, 'Bolso maternal', 'Bolso organizador con cambiador', 5, 95.00, 1),
('BEBE045', 45, 'Sombrilla para cochecito', 'Sombrilla universal con pinza', 5, 35.00, 1),
('BEBE046', 46, 'Funda para cochecito', 'Funda acolchada reversible', 5, 42.00, 1),
('BEBE047', 47, 'Protector para lluvia', 'Cobertor impermeable universal', 5, 28.00, 1),
('BEBE048', 48, 'Juguetes de viaje', 'Set de juguetes colgantes', 5, 32.00, 1),

-- Juguetes y estimulacion (IdCategoria = 6)
('BEBE049', 49, 'Mordillos', 'Set de mordillos de silicona', 6, 18.00, 1),
('BEBE050', 50, 'Sonajeros', 'Pack de 3 sonajeros coloridos', 6, 22.00, 1),
('BEBE051', 51, 'Alfombra de juegos', 'Alfombra acolchada con arcos', 6, 120.00, 1),
('BEBE052', 52, 'Gimnasio de actividades', 'Gimnasio con luces y sonidos', 6, 95.00, 1),
('BEBE053', 53, 'Peluches', 'Peluche suave hipoalergenico', 6, 35.00, 1),
('BEBE054', 54, 'Libros blandos', 'Set de 3 libros de tela', 6, 28.00, 1),
('BEBE055', 55, 'Cubos apilables', 'Set de cubos de colores', 6, 25.00, 1),
('BEBE056', 56, 'Juguetes para el bano', 'Set de juguetes flotantes', 6, 18.00, 1),
('BEBE057', 57, 'Aros de encastre', 'Torre de aros de colores', 6, 32.00, 1),
('BEBE058', 58, 'Juegos sensoriales', 'Set de texturas y sonidos', 6, 45.00, 1)

PRINT '   58 Productos de bebe creados'
PRINT ''

-- ============ 4. ASIGNAR PRODUCTOS A TIENDAS ============
PRINT '4. Asignando Productos a Tiendas...'

-- Verificar que existan tiendas
IF EXISTS (SELECT 1 FROM TIENDA WHERE IdTienda = 1)
BEGIN
    -- Sucursal Centro - Todos los productos
    INSERT INTO PRODUCTO_TIENDA (IdProducto, IdTienda, PrecioUnidadCompra, PrecioUnidadVenta, Stock, Activo, Iniciado) VALUES
    -- Ropa y accesorios
    (1, 1, 18.00, 25.00, 50, 1, 1),
    (2, 1, 35.00, 45.00, 40, 1, 1),
    (3, 1, 12.00, 18.00, 60, 1, 1),
    (4, 1, 8.00, 12.00, 45, 1, 1),
    (5, 1, 10.00, 15.00, 55, 1, 1),
    (6, 1, 28.00, 38.00, 35, 1, 1),
    (7, 1, 14.00, 20.00, 50, 1, 1),
    (8, 1, 42.00, 55.00, 30, 1, 1),
    (9, 1, 24.00, 32.00, 40, 1, 1),
    (10, 1, 36.00, 48.00, 25, 1, 1),
    -- Alimentacion
    (11, 1, 25.00, 35.00, 30, 1, 1),
    (12, 1, 10.00, 15.00, 50, 1, 1),
    (13, 1, 12.00, 18.00, 45, 1, 1),
    (14, 1, 90.00, 120.00, 15, 1, 1),
    (15, 1, 65.00, 85.00, 20, 1, 1),
    (16, 1, 32.00, 42.00, 35, 1, 1),
    (17, 1, 16.00, 22.00, 40, 1, 1),
    (18, 1, 140.00, 180.00, 10, 1, 1),
    (19, 1, 28.00, 38.00, 25, 1, 1),
    (20, 1, 20.00, 28.00, 35, 1, 1),
    -- Higiene y cuidado
    (21, 1, 35.00, 45.00, 80, 1, 1),
    (22, 1, 8.00, 12.00, 100, 1, 1),
    (23, 1, 18.00, 25.00, 50, 1, 1),
    (24, 1, 24.00, 32.00, 40, 1, 1),
    (25, 1, 20.00, 28.00, 35, 1, 1),
    (26, 1, 10.00, 15.00, 45, 1, 1),
    (27, 1, 42.00, 55.00, 25, 1, 1),
    (28, 1, 12.00, 18.00, 40, 1, 1),
    (29, 1, 8.00, 12.00, 50, 1, 1),
    (30, 1, 25.00, 35.00, 30, 1, 1),
    -- Descanso y confort
    (31, 1, 350.00, 450.00, 8, 1, 1),
    (32, 1, 90.00, 120.00, 15, 1, 1),
    (33, 1, 28.00, 38.00, 35, 1, 1),
    (34, 1, 35.00, 45.00, 20, 1, 1),
    (35, 1, 24.00, 32.00, 30, 1, 1),
    (36, 1, 50.00, 65.00, 18, 1, 1),
    (37, 1, 20.00, 28.00, 25, 1, 1),
    (38, 1, 42.00, 55.00, 22, 1, 1),
    (39, 1, 36.00, 48.00, 28, 1, 1),
    (40, 1, 58.00, 75.00, 20, 1, 1),
    -- Paseo y movilidad
    (41, 1, 650.00, 850.00, 5, 1, 1),
    (42, 1, 500.00, 650.00, 8, 1, 1),
    (43, 1, 140.00, 180.00, 12, 1, 1),
    (44, 1, 72.00, 95.00, 20, 1, 1),
    (45, 1, 25.00, 35.00, 30, 1, 1),
    (46, 1, 32.00, 42.00, 25, 1, 1),
    (47, 1, 20.00, 28.00, 28, 1, 1),
    (48, 1, 24.00, 32.00, 35, 1, 1),
    -- Juguetes y estimulacion
    (49, 1, 12.00, 18.00, 50, 1, 1),
    (50, 1, 16.00, 22.00, 45, 1, 1),
    (51, 1, 90.00, 120.00, 15, 1, 1),
    (52, 1, 72.00, 95.00, 18, 1, 1),
    (53, 1, 25.00, 35.00, 40, 1, 1),
    (54, 1, 20.00, 28.00, 35, 1, 1),
    (55, 1, 18.00, 25.00, 38, 1, 1),
    (56, 1, 12.00, 18.00, 42, 1, 1),
    (57, 1, 24.00, 32.00, 30, 1, 1),
    (58, 1, 35.00, 45.00, 25, 1, 1)
    
    PRINT '   Productos asignados a Sucursal Centro'
END

-- Sucursal Norte (si existe) - Productos seleccionados
IF EXISTS (SELECT 1 FROM TIENDA WHERE IdTienda = 2)
BEGIN
    INSERT INTO PRODUCTO_TIENDA (IdProducto, IdTienda, PrecioUnidadCompra, PrecioUnidadVenta, Stock, Activo, Iniciado) VALUES
    (1, 2, 18.00, 25.00, 30, 1, 1),
    (2, 2, 35.00, 45.00, 25, 1, 1),
    (3, 2, 12.00, 18.00, 40, 1, 1),
    (6, 2, 28.00, 38.00, 20, 1, 1),
    (11, 2, 25.00, 35.00, 20, 1, 1),
    (13, 2, 12.00, 18.00, 30, 1, 1),
    (21, 2, 35.00, 45.00, 50, 1, 1),
    (22, 2, 8.00, 12.00, 60, 1, 1),
    (32, 2, 90.00, 120.00, 10, 1, 1),
    (41, 2, 650.00, 850.00, 3, 1, 1),
    (49, 2, 12.00, 18.00, 35, 1, 1),
    (50, 2, 16.00, 22.00, 30, 1, 1)
    
    PRINT '   Productos asignados a Sucursal Norte'
END

-- Sucursal Sur (si existe) - Productos seleccionados
IF EXISTS (SELECT 1 FROM TIENDA WHERE IdTienda = 3)
BEGIN
    INSERT INTO PRODUCTO_TIENDA (IdProducto, IdTienda, PrecioUnidadCompra, PrecioUnidadVenta, Stock, Activo, Iniciado) VALUES
    (1, 3, 18.00, 25.00, 35, 1, 1),
    (4, 3, 8.00, 12.00, 40, 1, 1),
    (5, 3, 10.00, 15.00, 40, 1, 1),
    (11, 3, 25.00, 35.00, 25, 1, 1),
    (14, 3, 90.00, 120.00, 10, 1, 1),
    (21, 3, 35.00, 45.00, 55, 1, 1),
    (23, 3, 18.00, 25.00, 35, 1, 1),
    (33, 3, 28.00, 38.00, 25, 1, 1),
    (42, 3, 500.00, 650.00, 5, 1, 1),
    (51, 3, 90.00, 120.00, 12, 1, 1),
    (53, 3, 25.00, 35.00, 30, 1, 1),
    (55, 3, 18.00, 25.00, 28, 1, 1)
    
    PRINT '   Productos asignados a Sucursal Sur'
END

PRINT ''
PRINT '======================================'
PRINT 'ACTUALIZACION COMPLETADA'
PRINT '======================================'
PRINT ''
PRINT 'Resumen:'
PRINT '- 6 Categorias de productos de bebe'
PRINT '- 58 Productos de bebe'
PRINT '- Productos asignados a todas las tiendas disponibles'
PRINT ''

GO

