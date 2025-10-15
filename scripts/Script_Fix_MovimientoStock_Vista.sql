USE DBVENTAS_WEB
GO

-- =============================================
-- Script: Actualizacion de Proveedores para Productos de Bebe
-- Descripcion: Reemplaza proveedores existentes por proveedores especializados en articulos de bebe
-- =============================================

PRINT '======================================'
PRINT 'ACTUALIZANDO PROVEEDORES'
PRINT '======================================'
PRINT ''

-- ============ 1. LIMPIAR PROVEEDORES EXISTENTES ============
PRINT '1. Limpiando proveedores existentes...'

-- Deshabilitar constraints temporalmente
ALTER TABLE DETALLE_ORDEN_COMPRA NOCHECK CONSTRAINT ALL
ALTER TABLE ORDEN_COMPRA NOCHECK CONSTRAINT ALL
ALTER TABLE FACTURA NOCHECK CONSTRAINT ALL
ALTER TABLE REMITO NOCHECK CONSTRAINT ALL
ALTER TABLE PROVEEDOR NOCHECK CONSTRAINT ALL

-- Eliminar datos relacionados con proveedores
DELETE FROM DETALLE_FACTURA
DELETE FROM FACTURA
DELETE FROM DETALLE_REMITO
DELETE FROM REMITO
DELETE FROM DETALLE_ORDEN_COMPRA
DELETE FROM ORDEN_COMPRA
DELETE FROM PROVEEDOR

-- Resetear identities
DBCC CHECKIDENT ('DETALLE_FACTURA', RESEED, 0)
DBCC CHECKIDENT ('FACTURA', RESEED, 0)
DBCC CHECKIDENT ('DETALLE_REMITO', RESEED, 0)
DBCC CHECKIDENT ('REMITO', RESEED, 0)
DBCC CHECKIDENT ('DETALLE_ORDEN_COMPRA', RESEED, 0)
DBCC CHECKIDENT ('ORDEN_COMPRA', RESEED, 0)
DBCC CHECKIDENT ('PROVEEDOR', RESEED, 0)

-- Rehabilitar constraints
ALTER TABLE DETALLE_ORDEN_COMPRA CHECK CONSTRAINT ALL
ALTER TABLE ORDEN_COMPRA CHECK CONSTRAINT ALL
ALTER TABLE FACTURA CHECK CONSTRAINT ALL
ALTER TABLE REMITO CHECK CONSTRAINT ALL
ALTER TABLE PROVEEDOR CHECK CONSTRAINT ALL

PRINT '   Proveedores anteriores eliminados'
PRINT ''

-- ============ 2. INSERTAR NUEVOS PROVEEDORES DE PRODUCTOS DE BEBE ============
PRINT '2. Insertando Proveedores de Productos de Bebe...'

INSERT INTO PROVEEDOR (RUC, RazonSocial, Telefono, Correo, Direccion, Activo) VALUES
('20567890123', 'BabySoft Distribuidora', '011-4567-8901', 'ventas@babysoft.com', 'Av. Infantil 123, CABA', 1),
('20567890124', 'PequeMundo S.A.', '011-4567-8902', 'contacto@pequemundo.com', 'Calle Bebe 456, CABA', 1),
('20567890125', 'BebeLandia Imports', '011-4567-8903', 'pedidos@bebelandia.com', 'Jr. Maternal 789, CABA', 1),
('20567890126', 'MiniSuenos Hogar Infantil', '011-4567-8904', 'ventas@minisuenos.com', 'Av. Ninos 321, CABA', 1),
('20567890127', 'BabyCare Distribuciones', '011-4567-8905', 'info@babycare.com', 'Calle Puericultura 654, CABA', 1)

PRINT '   5 Proveedores creados'
PRINT ''

PRINT '======================================'
PRINT 'ACTUALIZACION COMPLETADA'
PRINT '======================================'
PRINT ''
PRINT 'Proveedores creados:'
PRINT '1. BabySoft Distribuidora'
PRINT '2. PequeMundo S.A.'
PRINT '3. BebeLandia Imports'
PRINT '4. MiniSuenos Hogar Infantil'
PRINT '5. BabyCare Distribuciones'
PRINT ''

GO
