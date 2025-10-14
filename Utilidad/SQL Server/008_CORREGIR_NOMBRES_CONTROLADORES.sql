USE DBVENTAS_WEB
GO

-- =============================================
-- Script: Corregir Nombres de Controladores
-- Descripción: Actualiza los nombres de controladores en SUBMENU
-- =============================================

PRINT '======================================'
PRINT 'CORRIGIENDO NOMBRES DE CONTROLADORES'
PRINT '======================================'
PRINT ''

-- Corregir controlador de Reportes (debe ser "Reportes" no "Reporte")
UPDATE SUBMENU 
SET Controlador = 'Reportes' 
WHERE Controlador = 'Reporte'
PRINT '✓ Controlador de Reportes corregido'

-- Verificar que los nombres estén correctos
PRINT ''
PRINT 'VERIFICACIÓN DE CONTROLADORES:'
SELECT 
    sm.Nombre as SubMenu,
    sm.Controlador,
    sm.Vista
FROM SUBMENU sm
WHERE sm.Controlador IN ('Reportes', 'Remito', 'Factura', 'Compra')
ORDER BY sm.Controlador, sm.Nombre

PRINT ''
PRINT '======================================'
PRINT '   ✓ CORRECCIÓN COMPLETADA'
PRINT '======================================'
GO
