using System.Web.Mvc;
using System.Web.Routing;

namespace VentasWeb
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            // --- ALIAS: aceptar /Reporte/Producto aunque el controlador sea Reportes ---
            routes.MapRoute(
                name: "AliasReporteProducto",
                url: "Reporte/Producto",
                defaults: new { controller = "Reportes", action = "Producto" }
            );

            // --- ALIAS: si en algún lado llaman /Reporte/ObtenerProducto (viejo) ---
            routes.MapRoute(
                name: "AliasReporteObtenerProducto",
                url: "Reporte/ObtenerProducto",
                defaults: new { controller = "Reportes", action = "ObtenerReporteProducto" }
            );

            // (opcional) alias para /Reporte/Venta -> /Reportes/Venta si lo usás
            routes.MapRoute(
                name: "AliasReporteVenta",
                url: "Reporte/Venta",
                defaults: new { controller = "Reportes", action = "Venta" } // si existe
            );

            // Ruta por defecto
            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
            );
        }
    }
}
