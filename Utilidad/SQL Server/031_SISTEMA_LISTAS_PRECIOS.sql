-- =============================================
-- SCRIPT: SISTEMA DE LISTAS DE PRECIOS CON VIGENCIA
-- Fecha: 2025-11-12
-- Descripción: Sistema completo de listas de precios para productos con vigencia temporal
-- =============================================

USE DBVENTAS_WEB
GO

-- =============================================
-- TABLA: LISTA_PRECIO
-- Descripción: Almacena las listas de precios (Mayorista, Minorista, etc.)
-- =============================================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'LISTA_PRECIO')
BEGIN
    CREATE TABLE LISTA_PRECIO(
        IdListaPrecio INT PRIMARY KEY IDENTITY(1,1),
        Nombre VARCHAR(100) NOT NULL,
        Descripcion VARCHAR(500),
        TipoLista VARCHAR(50) NOT NULL, -- 'Mayorista', 'Minorista', 'Promocion', etc.
        IdTienda INT REFERENCES TIENDA(IdTienda),
        Activo BIT DEFAULT 1,
        FechaRegistro DATETIME DEFAULT GETDATE()
    )
    
    PRINT 'Tabla LISTA_PRECIO creada exitosamente'
END
ELSE
BEGIN
    PRINT 'Tabla LISTA_PRECIO ya existe'
END
GO

-- =============================================
-- TABLA: LISTA_PRECIO_DETALLE
-- Descripción: Vincula productos con listas de precios, incluyendo precio y vigencia
-- =============================================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'LISTA_PRECIO_DETALLE')
BEGIN
    CREATE TABLE LISTA_PRECIO_DETALLE(
        IdListaPrecioDetalle INT PRIMARY KEY IDENTITY(1,1),
        IdListaPrecio INT REFERENCES LISTA_PRECIO(IdListaPrecio),
        IdProducto INT REFERENCES PRODUCTO(IdProducto),
        PrecioVenta DECIMAL(18,2) NOT NULL,
        FechaVigenciaDesde DATE NOT NULL,
        FechaVigenciaHasta DATE NOT NULL,
        Activo BIT DEFAULT 1,
        FechaRegistro DATETIME DEFAULT GETDATE()
    )
    
    -- Índices para mejorar rendimiento
    CREATE INDEX IX_LISTA_PRECIO_DETALLE_Lista ON LISTA_PRECIO_DETALLE(IdListaPrecio)
    CREATE INDEX IX_LISTA_PRECIO_DETALLE_Producto ON LISTA_PRECIO_DETALLE(IdProducto)
    CREATE INDEX IX_LISTA_PRECIO_DETALLE_Vigencia ON LISTA_PRECIO_DETALLE(FechaVigenciaDesde, FechaVigenciaHasta)
    
    PRINT 'Tabla LISTA_PRECIO_DETALLE creada exitosamente con índices'
END
ELSE
BEGIN
    PRINT 'Tabla LISTA_PRECIO_DETALLE ya existe'
END
GO

-- =============================================
-- SP: usp_ObtenerListasPrecios
-- Descripción: Obtiene todas las listas de precios
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerListasPrecios')
    DROP PROCEDURE usp_ObtenerListasPrecios
GO

CREATE PROCEDURE usp_ObtenerListasPrecios
    @IdTienda INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        lp.IdListaPrecio,
        lp.Nombre,
        lp.Descripcion,
        lp.TipoLista,
        lp.IdTienda,
        t.Nombre AS NombreTienda,
        lp.Activo,
        lp.FechaRegistro,
        COUNT(DISTINCT lpd.IdProducto) AS CantidadProductos,
        COUNT(CASE WHEN lpd.Activo = 1 AND GETDATE() BETWEEN lpd.FechaVigenciaDesde AND lpd.FechaVigenciaHasta THEN 1 END) AS ProductosVigentes
    FROM LISTA_PRECIO lp
    LEFT JOIN TIENDA t ON lp.IdTienda = t.IdTienda
    LEFT JOIN LISTA_PRECIO_DETALLE lpd ON lp.IdListaPrecio = lpd.IdListaPrecio
    WHERE (@IdTienda IS NULL OR lp.IdTienda = @IdTienda OR lp.IdTienda IS NULL)
    GROUP BY lp.IdListaPrecio, lp.Nombre, lp.Descripcion, lp.TipoLista, lp.IdTienda, t.Nombre, lp.Activo, lp.FechaRegistro
    ORDER BY lp.TipoLista, lp.Nombre
END
GO

-- =============================================
-- SP: usp_RegistrarListaPrecio
-- Descripción: Registra una nueva lista de precios
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_RegistrarListaPrecio')
    DROP PROCEDURE usp_RegistrarListaPrecio
GO

CREATE PROCEDURE usp_RegistrarListaPrecio
    @Nombre VARCHAR(100),
    @Descripcion VARCHAR(500),
    @TipoLista VARCHAR(50),
    @IdTienda INT = NULL,
    @Resultado BIT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    
    BEGIN TRY
        -- Validar que no existe una lista con el mismo nombre para la tienda
        IF EXISTS (SELECT 1 FROM LISTA_PRECIO WHERE Nombre = @Nombre AND (IdTienda = @IdTienda OR (IdTienda IS NULL AND @IdTienda IS NULL)))
        BEGIN
            SET @Mensaje = 'Ya existe una lista de precios con ese nombre'
            RETURN
        END
        
        INSERT INTO LISTA_PRECIO (Nombre, Descripcion, TipoLista, IdTienda)
        VALUES (@Nombre, @Descripcion, @TipoLista, @IdTienda)
        
        SET @Resultado = 1
        SET @Mensaje = 'Lista de precios registrada exitosamente'
    END TRY
    BEGIN CATCH
        SET @Mensaje = ERROR_MESSAGE()
    END CATCH
END
GO

-- =============================================
-- SP: usp_ModificarListaPrecio
-- Descripción: Modifica una lista de precios existente
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ModificarListaPrecio')
    DROP PROCEDURE usp_ModificarListaPrecio
GO

CREATE PROCEDURE usp_ModificarListaPrecio
    @IdListaPrecio INT,
    @Nombre VARCHAR(100),
    @Descripcion VARCHAR(500),
    @TipoLista VARCHAR(50),
    @Activo BIT,
    @Resultado BIT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    
    BEGIN TRY
        -- Validar que existe la lista
        IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO WHERE IdListaPrecio = @IdListaPrecio)
        BEGIN
            SET @Mensaje = 'La lista de precios no existe'
            RETURN
        END
        
        UPDATE LISTA_PRECIO
        SET Nombre = @Nombre,
            Descripcion = @Descripcion,
            TipoLista = @TipoLista,
            Activo = @Activo
        WHERE IdListaPrecio = @IdListaPrecio
        
        SET @Resultado = 1
        SET @Mensaje = 'Lista de precios modificada exitosamente'
    END TRY
    BEGIN CATCH
        SET @Mensaje = ERROR_MESSAGE()
    END CATCH
END
GO

-- =============================================
-- SP: usp_ObtenerProductosListaPrecio
-- Descripción: Obtiene los productos de una lista de precios con su vigencia
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerProductosListaPrecio')
    DROP PROCEDURE usp_ObtenerProductosListaPrecio
GO

CREATE PROCEDURE usp_ObtenerProductosListaPrecio
    @IdListaPrecio INT,
    @SoloVigentes BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        lpd.IdListaPrecioDetalle,
        lpd.IdListaPrecio,
        lpd.IdProducto,
        p.Codigo,
        p.Nombre AS NombreProducto,
        p.Descripcion AS DescripcionProducto,
        c.Descripcion AS Categoria,
        lpd.PrecioVenta,
        lpd.FechaVigenciaDesde,
        lpd.FechaVigenciaHasta,
        lpd.Activo,
        lpd.FechaRegistro,
        CASE 
            WHEN lpd.Activo = 1 AND GETDATE() BETWEEN lpd.FechaVigenciaDesde AND lpd.FechaVigenciaHasta THEN 1
            ELSE 0
        END AS EsVigente
    FROM LISTA_PRECIO_DETALLE lpd
    INNER JOIN PRODUCTO p ON lpd.IdProducto = p.IdProducto
    INNER JOIN CATEGORIA c ON p.IdCategoria = c.IdCategoria
    WHERE lpd.IdListaPrecio = @IdListaPrecio
        AND (@SoloVigentes = 0 OR (lpd.Activo = 1 AND GETDATE() BETWEEN lpd.FechaVigenciaDesde AND lpd.FechaVigenciaHasta))
    ORDER BY p.Nombre
END
GO

-- =============================================
-- SP: usp_AgregarProductoListaPrecio
-- Descripción: Agrega un producto a una lista de precios
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_AgregarProductoListaPrecio')
    DROP PROCEDURE usp_AgregarProductoListaPrecio
GO

CREATE PROCEDURE usp_AgregarProductoListaPrecio
    @IdListaPrecio INT,
    @IdProducto INT,
    @PrecioVenta DECIMAL(18,2),
    @FechaVigenciaDesde DATE,
    @FechaVigenciaHasta DATE,
    @Resultado BIT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    
    BEGIN TRY
        -- Validar que existe la lista
        IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO WHERE IdListaPrecio = @IdListaPrecio AND Activo = 1)
        BEGIN
            SET @Mensaje = 'La lista de precios no existe o no está activa'
            RETURN
        END
        
        -- Validar que existe el producto
        IF NOT EXISTS (SELECT 1 FROM PRODUCTO WHERE IdProducto = @IdProducto AND Activo = 1)
        BEGIN
            SET @Mensaje = 'El producto no existe o no está activo'
            RETURN
        END
        
        -- Validar fechas
        IF @FechaVigenciaDesde > @FechaVigenciaHasta
        BEGIN
            SET @Mensaje = 'La fecha de inicio debe ser menor o igual a la fecha de fin'
            RETURN
        END
        
        -- Validar precio
        IF @PrecioVenta <= 0
        BEGIN
            SET @Mensaje = 'El precio debe ser mayor a cero'
            RETURN
        END
        
        -- Validar que no exista solapamiento de vigencias para el mismo producto en la lista
        IF EXISTS (
            SELECT 1 FROM LISTA_PRECIO_DETALLE
            WHERE IdListaPrecio = @IdListaPrecio 
                AND IdProducto = @IdProducto
                AND Activo = 1
                AND (
                    (@FechaVigenciaDesde BETWEEN FechaVigenciaDesde AND FechaVigenciaHasta)
                    OR (@FechaVigenciaHasta BETWEEN FechaVigenciaDesde AND FechaVigenciaHasta)
                    OR (FechaVigenciaDesde BETWEEN @FechaVigenciaDesde AND @FechaVigenciaHasta)
                )
        )
        BEGIN
            SET @Mensaje = 'Ya existe un precio vigente para este producto en el rango de fechas especificado'
            RETURN
        END
        
        INSERT INTO LISTA_PRECIO_DETALLE (IdListaPrecio, IdProducto, PrecioVenta, FechaVigenciaDesde, FechaVigenciaHasta)
        VALUES (@IdListaPrecio, @IdProducto, @PrecioVenta, @FechaVigenciaDesde, @FechaVigenciaHasta)
        
        SET @Resultado = 1
        SET @Mensaje = 'Producto agregado a la lista de precios exitosamente'
    END TRY
    BEGIN CATCH
        SET @Mensaje = ERROR_MESSAGE()
    END CATCH
END
GO

-- =============================================
-- SP: usp_ModificarProductoListaPrecio
-- Descripción: Modifica un producto de una lista de precios
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ModificarProductoListaPrecio')
    DROP PROCEDURE usp_ModificarProductoListaPrecio
GO

CREATE PROCEDURE usp_ModificarProductoListaPrecio
    @IdListaPrecioDetalle INT,
    @PrecioVenta DECIMAL(18,2),
    @FechaVigenciaDesde DATE,
    @FechaVigenciaHasta DATE,
    @Activo BIT,
    @Resultado BIT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    
    BEGIN TRY
        DECLARE @IdListaPrecio INT, @IdProducto INT
        
        -- Obtener IdListaPrecio e IdProducto
        SELECT @IdListaPrecio = IdListaPrecio, @IdProducto = IdProducto
        FROM LISTA_PRECIO_DETALLE
        WHERE IdListaPrecioDetalle = @IdListaPrecioDetalle
        
        IF @IdListaPrecio IS NULL
        BEGIN
            SET @Mensaje = 'El registro no existe'
            RETURN
        END
        
        -- Validar fechas
        IF @FechaVigenciaDesde > @FechaVigenciaHasta
        BEGIN
            SET @Mensaje = 'La fecha de inicio debe ser menor o igual a la fecha de fin'
            RETURN
        END
        
        -- Validar precio
        IF @PrecioVenta <= 0
        BEGIN
            SET @Mensaje = 'El precio debe ser mayor a cero'
            RETURN
        END
        
        -- Validar que no exista solapamiento de vigencias (excluyendo el registro actual)
        IF @Activo = 1 AND EXISTS (
            SELECT 1 FROM LISTA_PRECIO_DETALLE
            WHERE IdListaPrecio = @IdListaPrecio 
                AND IdProducto = @IdProducto
                AND IdListaPrecioDetalle <> @IdListaPrecioDetalle
                AND Activo = 1
                AND (
                    (@FechaVigenciaDesde BETWEEN FechaVigenciaDesde AND FechaVigenciaHasta)
                    OR (@FechaVigenciaHasta BETWEEN FechaVigenciaDesde AND FechaVigenciaHasta)
                    OR (FechaVigenciaDesde BETWEEN @FechaVigenciaDesde AND @FechaVigenciaHasta)
                )
        )
        BEGIN
            SET @Mensaje = 'Ya existe un precio vigente para este producto en el rango de fechas especificado'
            RETURN
        END
        
        UPDATE LISTA_PRECIO_DETALLE
        SET PrecioVenta = @PrecioVenta,
            FechaVigenciaDesde = @FechaVigenciaDesde,
            FechaVigenciaHasta = @FechaVigenciaHasta,
            Activo = @Activo
        WHERE IdListaPrecioDetalle = @IdListaPrecioDetalle
        
        SET @Resultado = 1
        SET @Mensaje = 'Precio modificado exitosamente'
    END TRY
    BEGIN CATCH
        SET @Mensaje = ERROR_MESSAGE()
    END CATCH
END
GO

-- =============================================
-- SP: usp_EliminarProductoListaPrecio
-- Descripción: Elimina (desactiva) un producto de una lista de precios
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_EliminarProductoListaPrecio')
    DROP PROCEDURE usp_EliminarProductoListaPrecio
GO

CREATE PROCEDURE usp_EliminarProductoListaPrecio
    @IdListaPrecioDetalle INT,
    @Resultado BIT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Resultado = 0;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO_DETALLE WHERE IdListaPrecioDetalle = @IdListaPrecioDetalle)
        BEGIN
            SET @Mensaje = 'El registro no existe'
            RETURN
        END
        
        UPDATE LISTA_PRECIO_DETALLE
        SET Activo = 0
        WHERE IdListaPrecioDetalle = @IdListaPrecioDetalle
        
        SET @Resultado = 1
        SET @Mensaje = 'Precio eliminado exitosamente'
    END TRY
    BEGIN CATCH
        SET @Mensaje = ERROR_MESSAGE()
    END CATCH
END
GO

-- =============================================
-- SP: usp_ObtenerPrecioProductoVigente
-- Descripción: Obtiene el precio vigente de un producto según la lista de precios y fecha
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerPrecioProductoVigente')
    DROP PROCEDURE usp_ObtenerPrecioProductoVigente
GO

CREATE PROCEDURE usp_ObtenerPrecioProductoVigente
    @IdListaPrecio INT,
    @IdProducto INT,
    @Fecha DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @Fecha IS NULL
        SET @Fecha = GETDATE()
    
    SELECT TOP 1
        lpd.IdListaPrecioDetalle,
        lpd.IdListaPrecio,
        lp.Nombre AS NombreLista,
        lp.TipoLista,
        lpd.IdProducto,
        p.Nombre AS NombreProducto,
        lpd.PrecioVenta,
        lpd.FechaVigenciaDesde,
        lpd.FechaVigenciaHasta
    FROM LISTA_PRECIO_DETALLE lpd
    INNER JOIN LISTA_PRECIO lp ON lpd.IdListaPrecio = lp.IdListaPrecio
    INNER JOIN PRODUCTO p ON lpd.IdProducto = p.IdProducto
    WHERE lpd.IdListaPrecio = @IdListaPrecio
        AND lpd.IdProducto = @IdProducto
        AND lpd.Activo = 1
        AND lp.Activo = 1
        AND p.Activo = 1
        AND @Fecha BETWEEN lpd.FechaVigenciaDesde AND lpd.FechaVigenciaHasta
    ORDER BY lpd.FechaVigenciaDesde DESC
END
GO

-- =============================================
-- SP: usp_ObtenerProductosDisponiblesParaLista
-- Descripción: Obtiene productos que pueden ser agregados a una lista (no tienen precio vigente)
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerProductosDisponiblesParaLista')
    DROP PROCEDURE usp_ObtenerProductosDisponiblesParaLista
GO

CREATE PROCEDURE usp_ObtenerProductosDisponiblesParaLista
    @IdListaPrecio INT,
    @FechaDesde DATE,
    @FechaHasta DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        p.IdProducto,
        p.Codigo,
        p.Nombre,
        p.Descripcion,
        c.Descripcion AS Categoria,
        p.Activo
    FROM PRODUCTO p
    INNER JOIN CATEGORIA c ON p.IdCategoria = c.IdCategoria
    WHERE p.Activo = 1
        AND NOT EXISTS (
            SELECT 1 FROM LISTA_PRECIO_DETALLE lpd
            WHERE lpd.IdListaPrecio = @IdListaPrecio
                AND lpd.IdProducto = p.IdProducto
                AND lpd.Activo = 1
                AND (
                    (@FechaDesde BETWEEN lpd.FechaVigenciaDesde AND lpd.FechaVigenciaHasta)
                    OR (@FechaHasta BETWEEN lpd.FechaVigenciaDesde AND lpd.FechaVigenciaHasta)
                    OR (lpd.FechaVigenciaDesde BETWEEN @FechaDesde AND @FechaHasta)
                )
        )
    ORDER BY p.Nombre
END
GO

PRINT '=================================='
PRINT 'SCRIPT EJECUTADO EXITOSAMENTE'
PRINT 'Sistema de Listas de Precios creado'
PRINT '=================================='
PRINT ''
PRINT 'Tablas creadas:'
PRINT '- LISTA_PRECIO'
PRINT '- LISTA_PRECIO_DETALLE'
PRINT ''
PRINT 'Stored Procedures creados:'
PRINT '- usp_ObtenerListasPrecios'
PRINT '- usp_RegistrarListaPrecio'
PRINT '- usp_ModificarListaPrecio'
PRINT '- usp_ObtenerProductosListaPrecio'
PRINT '- usp_AgregarProductoListaPrecio'
PRINT '- usp_ModificarProductoListaPrecio'
PRINT '- usp_EliminarProductoListaPrecio'
PRINT '- usp_ObtenerPrecioProductoVigente'
PRINT '- usp_ObtenerProductosDisponiblesParaLista'
GO
