USE DBVENTAS_WEB
GO

-- =============================================
-- DIAGNÓSTICO ESPECÍFICO: PROBLEMA AL GUARDAR ORDEN DE COMPRA
-- =============================================

PRINT '╔════════════════════════════════════════════════╗'
PRINT '║  DIAGNÓSTICO: GUARDAR ORDEN DE COMPRA         ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''

-- 1. Verificar que existe la tabla ORDEN_COMPRA
PRINT '1. Verificando tabla ORDEN_COMPRA...'
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ORDEN_COMPRA')
BEGIN
    PRINT '   ✓ Tabla ORDEN_COMPRA existe'
    
    -- Mostrar estructura
    PRINT '   Columnas:'
    SELECT 
        '      - ' + COLUMN_NAME + ' (' + DATA_TYPE + ')' AS Columna
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'ORDEN_COMPRA'
    ORDER BY ORDINAL_POSITION
END
ELSE
BEGIN
    PRINT '   ❌ ERROR: Tabla ORDEN_COMPRA NO existe'
    PRINT '   SOLUCIÓN: Ejecutar 000_EJECUTAR_TODO.sql'
END
PRINT ''

-- 2. Verificar que existe la tabla DETALLE_ORDEN_COMPRA
PRINT '2. Verificando tabla DETALLE_ORDEN_COMPRA...'
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DETALLE_ORDEN_COMPRA')
BEGIN
    PRINT '   ✓ Tabla DETALLE_ORDEN_COMPRA existe'
END
ELSE
BEGIN
    PRINT '   ❌ ERROR: Tabla DETALLE_ORDEN_COMPRA NO existe'
    PRINT '   SOLUCIÓN: Ejecutar 000_EJECUTAR_TODO.sql'
END
PRINT ''

-- 3. Verificar stored procedure usp_RegistrarCompra
PRINT '3. Verificando stored procedure usp_RegistrarCompra...'
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_RegistrarCompra')
BEGIN
    PRINT '   ✓ SP usp_RegistrarCompra existe'
    
    -- Verificar parámetros
    DECLARE @Params TABLE (Parametro VARCHAR(100))
    INSERT INTO @Params
    SELECT PARAMETER_NAME
    FROM INFORMATION_SCHEMA.PARAMETERS
    WHERE SPECIFIC_NAME = 'usp_RegistrarCompra'
    
    PRINT '   Parámetros:'
    SELECT '      - ' + Parametro AS Parametro FROM @Params
    
    -- Verificar contenido del SP
    DECLARE @SPContent NVARCHAR(MAX)
    SELECT @SPContent = OBJECT_DEFINITION(OBJECT_ID('usp_RegistrarCompra'))
    
    IF @SPContent LIKE '%ORDEN_COMPRA%'
        PRINT '   ✓ SP usa tabla ORDEN_COMPRA (correcto)'
    ELSE
    BEGIN
        PRINT '   ❌ SP usa tabla COMPRA (incorrecto)'
        PRINT '   SOLUCIÓN: Ejecutar 010_CORREGIR_TODO_FINAL.sql'
    END
    
    IF @SPContent LIKE '%DETALLE_ORDEN_COMPRA%'
        PRINT '   ✓ SP usa tabla DETALLE_ORDEN_COMPRA (correcto)'
    ELSE
    BEGIN
        PRINT '   ❌ SP usa tabla DETALLE_COMPRA (incorrecto)'
        PRINT '   SOLUCIÓN: Ejecutar 010_CORREGIR_TODO_FINAL.sql'
    END
    
    IF @SPContent LIKE '%@Resultado%'
        PRINT '   ✓ SP tiene parámetro @Resultado'
    ELSE
    BEGIN
        PRINT '   ⚠️  SP NO tiene parámetro @Resultado'
        PRINT '   SOLUCIÓN: Ejecutar 010_CORREGIR_TODO_FINAL.sql'
    END
END
ELSE
BEGIN
    PRINT '   ❌ ERROR: SP usp_RegistrarCompra NO existe'
    PRINT '   SOLUCIÓN: Ejecutar 009_STORED_PROCEDURES_COMPLETO.sql'
END
PRINT ''

-- 4. TEST DE INSERCIÓN MANUAL
PRINT '4. Testeando inserción manual en ORDEN_COMPRA...'
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ORDEN_COMPRA')
BEGIN
    BEGIN TRY
        -- Obtener IDs válidos
        DECLARE @TestUsuario INT, @TestProveedor INT, @TestTienda INT
        
        SELECT TOP 1 @TestUsuario = IdUsuario FROM USUARIO WHERE Activo = 1
        SELECT TOP 1 @TestProveedor = IdProveedor FROM PROVEEDOR WHERE Activo = 1
        SELECT TOP 1 @TestTienda = IdTienda FROM TIENDA WHERE Activo = 1
        
        IF @TestUsuario IS NULL OR @TestProveedor IS NULL OR @TestTienda IS NULL
        BEGIN
            PRINT '   ⚠️  No hay datos base (Usuario, Proveedor o Tienda)'
            PRINT '   SOLUCIÓN: Ejecutar 007_SEED_DATOS_PRUEBA_COMPLETO.sql'
        END
        ELSE
        BEGIN
            -- Intentar insertar
            INSERT INTO ORDEN_COMPRA(IdUsuario, IdProveedor, IdTienda, TotalCosto, Estado)
            VALUES(@TestUsuario, @TestProveedor, @TestTienda, 999.99, 'TEST')
            
            DECLARE @TestId INT = SCOPE_IDENTITY()
            
            IF @TestId > 0
            BEGIN
                PRINT '   ✓ Inserción manual funciona correctamente'
                PRINT '   ID generado: ' + CAST(@TestId AS VARCHAR(10))
                
                -- Limpiar test
                DELETE FROM ORDEN_COMPRA WHERE IdCompra = @TestId
                PRINT '   ✓ Registro de prueba eliminado'
            END
        END
    END TRY
    BEGIN CATCH
        PRINT '   ❌ ERROR al insertar: ' + ERROR_MESSAGE()
    END CATCH
END
PRINT ''

-- 5. TEST DEL STORED PROCEDURE
PRINT '5. Testeando stored procedure usp_RegistrarCompra...'
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_RegistrarCompra')
BEGIN
    BEGIN TRY
        DECLARE @TestResultado BIT
        DECLARE @XMLTest XML
        
        -- Obtener IDs válidos para el test
        DECLARE @IdU INT, @IdP INT, @IdT INT, @IdProd INT
        SELECT TOP 1 @IdU = IdUsuario FROM USUARIO WHERE Activo = 1
        SELECT TOP 1 @IdP = IdProveedor FROM PROVEEDOR WHERE Activo = 1
        SELECT TOP 1 @IdT = IdTienda FROM TIENDA WHERE Activo = 1
        SELECT TOP 1 @IdProd = IdProducto FROM PRODUCTO WHERE Activo = 1
        
        IF @IdU IS NULL OR @IdP IS NULL OR @IdT IS NULL OR @IdProd IS NULL
        BEGIN
            PRINT '   ⚠️  No hay datos suficientes para probar'
            PRINT '   SOLUCIÓN: Ejecutar 007_SEED_DATOS_PRUEBA_COMPLETO.sql'
        END
        ELSE
        BEGIN
            -- Crear XML de prueba
            SET @XMLTest = 
            '<DETALLE>
                <COMPRA>
                    <IdUsuario>' + CAST(@IdU AS VARCHAR(10)) + '</IdUsuario>
                    <IdProveedor>' + CAST(@IdP AS VARCHAR(10)) + '</IdProveedor>
                    <IdTienda>' + CAST(@IdT AS VARCHAR(10)) + '</IdTienda>
                    <TotalCosto>100.00</TotalCosto>
                </COMPRA>
                <DETALLE_COMPRA>
                    <DETALLE>
                        <IdCompra>0</IdCompra>
                        <IdProducto>' + CAST(@IdProd AS VARCHAR(10)) + '</IdProducto>
                        <Cantidad>1</Cantidad>
                        <PrecioUnidadCompra>50.00</PrecioUnidadCompra>
                        <PrecioUnidadVenta>100.00</PrecioUnidadVenta>
                        <TotalCosto>50.00</TotalCosto>
                    </DETALLE>
                </DETALLE_COMPRA>
            </DETALLE>'
            
            EXEC usp_RegistrarCompra @Detalle = @XMLTest, @Resultado = @TestResultado OUTPUT
            
            IF @TestResultado = 1
            BEGIN
                PRINT '   ✅ SP ejecuta correctamente'
                
                -- Obtener último registro insertado
                DECLARE @UltimoId INT
                SELECT TOP 1 @UltimoId = IdCompra FROM ORDEN_COMPRA ORDER BY IdCompra DESC
                
                PRINT '   ✓ Orden de Compra creada con ID: ' + CAST(@UltimoId AS VARCHAR(10))
                
                -- Verificar detalle
                DECLARE @CantDetalle INT
                SELECT @CantDetalle = COUNT(*) FROM DETALLE_ORDEN_COMPRA WHERE IdOrdenCompra = @UltimoId
                PRINT '   ✓ Registros de detalle: ' + CAST(@CantDetalle AS VARCHAR(10))
                
                -- Limpiar test
                DELETE FROM DETALLE_ORDEN_COMPRA WHERE IdOrdenCompra = @UltimoId
                DELETE FROM ORDEN_COMPRA WHERE IdCompra = @UltimoId
                PRINT '   ✓ Registros de prueba eliminados'
            END
            ELSE
            BEGIN
                PRINT '   ❌ ERROR: SP retorna @Resultado = 0 (falló)'
            END
        END
    END TRY
    BEGIN CATCH
        PRINT '   ❌ ERROR al ejecutar SP: ' + ERROR_MESSAGE()
        PRINT '   Error Número: ' + CAST(ERROR_NUMBER() AS VARCHAR(10))
        PRINT '   Línea: ' + CAST(ERROR_LINE() AS VARCHAR(10))
    END CATCH
END
PRINT ''

-- RESUMEN
PRINT ''
PRINT '╔════════════════════════════════════════════════╗'
PRINT '║              RESUMEN DEL DIAGNÓSTICO           ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''

DECLARE @ErrorCount INT = 0

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ORDEN_COMPRA')
BEGIN
    SET @ErrorCount = @ErrorCount + 1
    PRINT '❌ PROBLEMA 1: Tabla ORDEN_COMPRA no existe'
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_RegistrarCompra')
BEGIN
    SET @ErrorCount = @ErrorCount + 1
    PRINT '❌ PROBLEMA 2: SP usp_RegistrarCompra no existe'
END

IF @ErrorCount = 0
    PRINT '✅ ESTRUCTURA DE BD: CORRECTA'
ELSE
    PRINT '❌ HAY ' + CAST(@ErrorCount AS VARCHAR(5)) + ' PROBLEMA(S) EN LA ESTRUCTURA'

PRINT ''
PRINT 'PRÓXIMO PASO:'
PRINT '  Si hay ❌, ejecutar en orden:'
PRINT '    1. 000_EJECUTAR_TODO.sql'
PRINT '    2. 009_STORED_PROCEDURES_COMPLETO.sql'
PRINT '    3. 010_CORREGIR_TODO_FINAL.sql'
PRINT '    4. Este diagnóstico nuevamente'
PRINT ''
PRINT '  Si todo está ✅:'
PRINT '    - Abre la aplicación web'
PRINT '    - Abre consola del navegador (F12)'
PRINT '    - Intenta guardar orden de compra'
PRINT '    - Copia EXACTAMENTE el error que aparece'
PRINT ''
GO
