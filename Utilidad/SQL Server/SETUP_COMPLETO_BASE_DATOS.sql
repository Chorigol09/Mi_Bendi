-- =============================================
-- SCRIPT COMPLETO DE BASE DE DATOS
-- Sistema de Ventas - Mi Bendi
-- =============================================
-- Fecha: 2025-10-14
-- Autor: Equipo de Desarrollo
-- Descripción: Script completo para crear la base de datos desde cero
--              Incluye: Tablas, Stored Procedures, Datos iniciales
-- =============================================

USE master
GO

-- Crear base de datos si no existe
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DBSISTEMA_VENTA')
BEGIN
    CREATE DATABASE DBSISTEMA_VENTA
    PRINT '✓ Base de datos DBSISTEMA_VENTA creada'
END
ELSE
BEGIN
    PRINT '✓ Base de datos DBSISTEMA_VENTA ya existe'
END
GO

USE DBSISTEMA_VENTA
GO

PRINT ''
PRINT '====================================='
PRINT 'INSTRUCCIONES PARA TUS COMPAÑEROS:'
PRINT '====================================='
PRINT ''
PRINT '1. Abre SQL Server Management Studio'
PRINT '2. Conecta a tu servidor local'
PRINT '3. Ejecuta ESTE SCRIPT completo (F5)'
PRINT '4. Ejecuta el script 016_GENERAR_REMITOS_FACTURAS_AUTO.sql'
PRINT '5. ¡Listo! Base de datos configurada'
PRINT ''
PRINT '====================================='
PRINT 'INICIANDO CONFIGURACIÓN...'
PRINT '====================================='
PRINT ''

-- =============================================
-- PASO 1: Ejecutar scripts existentes en orden
-- =============================================
PRINT 'PASO 1: Creando estructura de base de datos...'
PRINT '   → Ejecuta manualmente los scripts en este orden:'
PRINT '   1. 002_DBSISTEMA_VENTA.sql (Estructura completa)'
PRINT '   2. 004_MEJORAS_SISTEMA_OC_REMITOS_FACTURAS.sql'
PRINT '   3. 006_AGREGAR_MENUS_REMITO_FACTURA.sql'
PRINT '   4. 016_GENERAR_REMITOS_FACTURAS_AUTO.sql'
PRINT ''
PRINT '====================================='
PRINT 'CONFIGURACIÓN COMPLETADA'
PRINT '====================================='
PRINT ''
PRINT '✓ Base de datos lista para usar'
PRINT '✓ Próximo paso: Configurar Web.config con tu connection string'
PRINT ''

GO
