# Solucion: Error 404 en Orden de Pago

## Problema
Al intentar acceder a las paginas `/OrdenPago/Registrar` y `/OrdenPago/Consultar` se obtenia un error 404 (recurso no encontrado).

## Causa
Los archivos relacionados con Orden de Pago existian pero NO estaban incluidos en los archivos de proyecto (.csproj), por lo que no se compilaban con la aplicacion.

## Archivos que faltaban incluir

### 1. VentasWeb.csproj
- **OrdenPagoController.cs** - El controlador principal
- **OrdenPago_Consultar.js** - Script JavaScript para la pagina Consultar
- **OrdenPago_Registrar.js** - Script JavaScript para la pagina Registrar

### 2. CapaModelo.csproj
- **OrdenPago.cs** - Clase modelo de Orden de Pago

### 3. CapaDatos.csproj
- **CD_OrdenPago.cs** - Capa de acceso a datos para Orden de Pago

## Solucion aplicada
Se agregaron todos los archivos faltantes a sus respectivos proyectos .csproj y se recompilo exitosamente.

## Pasos siguientes
1. **DETENER** la aplicacion web si esta corriendo (Ctrl+C en la consola)
2. **REINICIAR** la aplicacion ejecutando: `.\ejecutar.ps1` o presionando F5 en Visual Studio
3. Una vez reiniciada, intenta acceder nuevamente a:
   - http://localhost:[puerto]/OrdenPago/Registrar
   - http://localhost:[puerto]/OrdenPago/Consultar

## Resultado esperado
Ahora deberas poder acceder a ambas paginas sin error 404.
