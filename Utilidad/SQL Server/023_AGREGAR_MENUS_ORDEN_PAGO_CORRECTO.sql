Use DBVENTAS_WEB
-- Verifica que los menús existan
SELECT * FROM MENU WHERE Nombre = 'Órdenes de Pago'
SELECT * FROM SUBMENU WHERE Nombre LIKE '%Orden%Pago%'