USE [DBVENTAS_WEB]
GO

-- Ver todos los usuarios
SELECT 
    IdUsuario,
    Nombres,
    Apellidos,
    Correo,
    NombreUsuario,
    Activo
FROM USUARIO
WHERE Activo = 1
ORDER BY IdUsuario
GO
