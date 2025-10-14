using CapaDatos;
using CapaModelo;
using System;
using System.Linq;
using System.Web.Mvc;

namespace VentasWeb.Controllers
{
    public class ReportesController : Controller
    {
        [HttpGet]
        public ActionResult Producto()
        {
            return View("~/Views/Reporte/Producto.cshtml");
        }

        [HttpGet]
        public ActionResult Ventas()
        {
            return View("~/Views/Reporte/Ventas.cshtml");
        }

        [HttpGet]
        public JsonResult ObtenerVenta(string fechainicio, string fechafin, int idtienda = 0)
        {
            try
            {
                DateTime dtFechaInicio = DateTime.ParseExact(fechainicio, "dd/MM/yyyy", System.Globalization.CultureInfo.InvariantCulture);
                DateTime dtFechaFin = DateTime.ParseExact(fechafin, "dd/MM/yyyy", System.Globalization.CultureInfo.InvariantCulture);

                var lista = CD_Reportes.Instancia.ReporteVenta(dtFechaInicio, dtFechaFin, idtienda);
                return Json(lista, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { error = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // GET: /Reportes/ObtenerReporteProducto  -> devuelve el JSON para la grilla
        [HttpGet]
        public JsonResult ObtenerReporteProducto(int idtienda = 0, string codigoproducto = "")
        {
            // Productos activos
            var productos = CD_Producto.Instancia.ObtenerProducto()
                              .Where(p => p.Activo).ToList();

            // Relación producto–tienda
            var productosTienda = CD_ProductoTienda.Instancia.ObtenerProductoTienda().ToList();

            // Filtro por tienda
            if (idtienda != 0)
                productosTienda = productosTienda
                    .Where(pt => pt.oTienda.IdTienda == idtienda).ToList();

            // Filtro por código (case-insensitive simple)
            if (!string.IsNullOrWhiteSpace(codigoproducto))
                productos = productos
                    .Where(p => (p.Codigo ?? string.Empty)
                        .IndexOf(codigoproducto, StringComparison.OrdinalIgnoreCase) >= 0)
                    .ToList();

            // Proyección: usamos el PrecioVenta de PRODUCTO_TIENDA (específico por tienda)
            var data = (from pt in productosTienda
                        join p in productos on pt.oProducto.IdProducto equals p.IdProducto
                        select new
                        {
                            IdProducto = p.IdProducto,
                            IdProductoTienda = pt.IdProductoTienda,  // ← Agregado
                            IdTienda = pt.oTienda.IdTienda,
                            RucTienda = pt.oTienda.RUC,
                            NombreTienda = pt.oTienda.Nombre,
                            DireccionTienda = pt.oTienda.Direccion,
                            CodigoProducto = p.Codigo,
                            NombreProducto = p.Nombre,
                            DescripcionProducto = p.Descripcion,
                            StockenTienda = pt.Stock,
                            PrecioVenta = pt.PrecioUnidadVenta   // ← Cambiado a PRODUCTO_TIENDA
                        }).ToList();

            return Json(data, JsonRequestBehavior.AllowGet);
        }


    }
}
