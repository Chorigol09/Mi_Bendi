USE DBVENTAS_WEB
GO

-- =============================================
-- Script: Diagnóstico de Órdenes de Compra y Facturas
-- Descripción: Verificar estado de las órdenes y facturas
-- =============================================

PRINT '╔════════════════════════════════════════════════╗'
PRINT '║  DIAGNÓSTICO: ÓRDENES DE COMPRA Y FACTURAS    ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''

-- ============================================================
-- 1. VERIFICAR ÓRDENES DE COMPRA
-- ============================================================
PRINT '1. Verificando Órdenes de Compra...'
PRINT ''

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ORDEN_COMPRA')
BEGIN
    DECLARE @TotalOrdenes INT
    DECLARE @OrdenesActivas INT
    DECLARE @OrdenesInactivas INT
    
    SELECT @TotalOrdenes = COUNT(*) FROM ORDEN_COMPRA
    SELECT @OrdenesActivas = COUNT(*) FROM ORDEN_COMPRA WHERE Activo = 1
    SELECT @OrdenesInactivas = COUNT(*) FROM ORDEN_COMPRA WHERE Activo = 0
    
    PRINT '   Total de Órdenes de Compra: ' + CAST(@TotalOrdenes AS VARCHAR(10))
    PRINT '   Órdenes Activas: ' + CAST(@OrdenesActivas AS VARCHAR(10))
    PRINT '   Órdenes Inactivas: ' + CAST(@OrdenesInactivas AS VARCHAR(10))
    PRINT ''
    
    IF @TotalOrdenes > 0
    BEGIN
        PRINT '   Últimas 10 Órdenes de Compra:'
        SELECT TOP 10
            IdCompra AS 'ID',
            CONVERT(VARCHAR(10), FechaRegistro, 103) AS 'Fecha',
            TotalCosto AS 'Total',
            Estado,
            Activo,
            IdProveedor,
            IdTienda
        FROM ORDEN_COMPRA
        ORDER BY IdCompra DESC
    END
    ELSE
    BEGIN
        PRINT '   ⚠ NO HAY ÓRDENES DE COMPRA EN LA BASE DE DATOS'
    END
END
ELSE
BEGIN
    PRINT '   ❌ ERROR: Tabla ORDEN_COMPRA no existe'
END
PRINT ''
PRINT '---------------------------------------------------'
PRINT ''

-- ============================================================
-- 2. VERIFICAR FACTURAS
-- ============================================================
PRINT '2. Verificando Facturas...'
PRINT ''

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'FACTURA')
BEGIN
    DECLARE @TotalFacturas INT
    DECLARE @FacturasActivas INT
    DECLARE @FacturasInactivas INT
    
    SELECT @TotalFacturas = COUNT(*) FROM FACTURA
    SELECT @FacturasActivas = COUNT(*) FROM FACTURA WHERE Activo = 1
    SELECT @FacturasInactivas = COUNT(*) FROM FACTURA WHERE Activo = 0
    
    PRINT '   Total de Facturas: ' + CAST(@TotalFacturas AS VARCHAR(10))
    PRINT '   Facturas Activas: ' + CAST(@FacturasActivas AS VARCHAR(10))
    PRINT '   Facturas Inactivas: ' + CAST(@FacturasInactivas AS VARCHAR(10))
    PRINT ''
    
    IF @TotalFacturas > 0
    BEGIN
        PRINT '   Últimas 10 Facturas:'
        SELECT TOP 10
            IdFactura AS 'ID',
            NumeroFactura AS 'Número',
            CONVERT(VARCHAR(10), FechaEmision, 103) AS 'Fecha Emisión',
            Total,
            Estado,
            Activo,
            IdProveedor,
            ISNULL(IdTienda, 0) AS 'IdTienda'
        FROM FACTURA
        ORDER BY IdFactura DESC
    END
    ELSE
    BEGIN
        PRINT '   ⚠ NO HAY FACTURAS EN LA BASE DE DATOS'
    END
END
ELSE
BEGIN
    PRINT '   ❌ ERROR: Tabla FACTURA no existe'
END
PRINT ''
PRINT '---------------------------------------------------'
PRINT ''

-- ============================================================
-- 3. VERIFICAR DETALLES
-- ============================================================
PRINT '3. Verificando Detalles...'
PRINT ''

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DETALLE_ORDEN_COMPRA')
BEGIN
    DECLARE @TotalDetallesOC INT
    SELECT @TotalDetallesOC = COUNT(*) FROM DETALLE_ORDEN_COMPRA
    PRINT '   Total Detalles Orden Compra: ' + CAST(@TotalDetallesOC AS VARCHAR(10))
END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DETALLE_FACTURA')
BEGIN
    DECLARE @TotalDetallesFactura INT
    SELECT @TotalDetallesFactura = COUNT(*) FROM DETALLE_FACTURA
    PRINT '   Total Detalles Factura: ' + CAST(@TotalDetallesFactura AS VARCHAR(10))
END
PRINT ''
PRINT '---------------------------------------------------'
PRINT ''

-- ============================================================
-- 4. VERIFICAR STORED PROCEDURES
-- ============================================================
PRINT '4. Verificando Stored Procedures...'
PRINT ''

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_RegistrarCompra')
BEGIN
    PRINT '   ✓ usp_RegistrarCompra existe'
    
    IF EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.PARAMETERS 
        WHERE SPECIFIC_NAME = 'usp_RegistrarCompra' 
        AND PARAMETER_NAME = '@Resultado'
    )
        PRINT '     ✓ Tiene parámetro @Resultado'
    ELSE
        PRINT '     ❌ NO tiene parámetro @Resultado (PROBLEMA)'
END
ELSE
    PRINT '   ❌ usp_RegistrarCompra NO existe'

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_RegistrarFacturaConDetalles')
BEGIN
    PRINT '   ✓ usp_RegistrarFacturaConDetalles existe'
    
    IF EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.PARAMETERS 
        WHERE SPECIFIC_NAME = 'usp_RegistrarFacturaConDetalles' 
        AND PARAMETER_NAME = '@Resultado'
    )
        PRINT '     ✓ Tiene parámetro @Resultado'
    ELSE
        PRINT '     ❌ NO tiene parámetro @Resultado (PROBLEMA)'
END
ELSE
    PRINT '   ❌ usp_RegistrarFacturaConDetalles NO existe'

PRINT ''
PRINT '=========================================='
PRINT 'Diagnóstico completado'
PRINT '=========================================='
PRINT ''
GO
