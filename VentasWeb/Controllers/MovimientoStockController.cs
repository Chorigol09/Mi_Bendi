using CapaDatos;
using CapaModelo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace VentasWeb.Controllers
{
    public class MovimientoStockController : Controller
    {
        // GET: MovimientoStock
        public ActionResult Crear()
        {
            return View();
        }

        [HttpGet]
        public JsonResult Obtener(int idTienda = 0)
        {
            List<MovimientoStock> lista = CD_MovimientoStock.Instancia.ObtenerMovimientos(idTienda);
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult ObtenerAgrupados(int idTienda = 0)
        {
            List<MovimientoStock> lista = CD_MovimientoStock.Instancia.ObtenerMovimientos(idTienda);
            
            // Agrupar por IdLote
            var agrupados = lista
                .GroupBy(m => string.IsNullOrEmpty(m.IdLote) ? Guid.NewGuid().ToString() : m.IdLote)
                .Select(g => new
                {
                    IdLote = g.First().IdLote,
                    FechaRegistro = g.First().FechaRegistro,
                    oTienda = g.First().oTienda,
                    TipoMovimiento = g.First().TipoMovimiento,
                    Motivo = g.First().Motivo,
                    oUsuario = g.First().oUsuario,
                    CantidadProductos = g.Count(),
                    ProductosResumen = string.Join(", ", g.Take(2).Select(m => m.oProducto.Nombre)) + (g.Count() > 2 ? "..." : ""),
                    TotalCantidad = g.Sum(m => m.Cantidad)
                })
                .OrderByDescending(x => x.FechaRegistro)
                .ToList();

            return Json(new { data = agrupados }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult ObtenerProductosPorTienda(int idTienda)
        {
            List<ProductoTienda> listaProductoTienda = CD_ProductoTienda.Instancia.ObtenerProductoTienda();
            listaProductoTienda = listaProductoTienda.Where(x => x.oTienda.IdTienda == idTienda).ToList();
            
            // Mapear a lista de productos con información de la tienda
            var productos = listaProductoTienda.Select(pt => new
            {
                IdProducto = pt.oProducto.IdProducto,
                Codigo = pt.oProducto.Codigo,
                Nombre = pt.oProducto.Nombre,
                Descripcion = pt.oProducto.Descripcion,
                oCategoria = new { Descripcion = pt.oProducto.oCategoria != null ? pt.oProducto.oCategoria.Descripcion : "Sin Categoría" },
                StockActual = pt.Stock
            }).ToList();

            return Json(new { data = productos }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult Guardar(MovimientoStock objeto)
        {
            try
            {
                // Validaciones básicas
                if (objeto.oTienda == null || objeto.oTienda.IdTienda == 0)
                {
                    return Json(new { resultado = false, mensaje = "Debe seleccionar una tienda" }, JsonRequestBehavior.AllowGet);
                }

                if (objeto.oProducto == null || objeto.oProducto.IdProducto == 0)
                {
                    return Json(new { resultado = false, mensaje = "Debe seleccionar un producto" }, JsonRequestBehavior.AllowGet);
                }

                if (objeto.Cantidad <= 0)
                {
                    return Json(new { resultado = false, mensaje = "La cantidad debe ser mayor a cero" }, JsonRequestBehavior.AllowGet);
                }

                if (string.IsNullOrEmpty(objeto.TipoMovimiento))
                {
                    return Json(new { resultado = false, mensaje = "Debe seleccionar un tipo de movimiento" }, JsonRequestBehavior.AllowGet);
                }

                // Obtener el usuario de la sesión
                if (Session["Usuario"] != null)
                {
                    Usuario usuarioSesion = (Usuario)Session["Usuario"];
                    objeto.oUsuario = new Usuario() { IdUsuario = usuarioSesion.IdUsuario };
                }
                else
                {
                    objeto.oUsuario = new Usuario() { IdUsuario = 1 }; // Usuario por defecto
                }

                bool respuesta = CD_MovimientoStock.Instancia.RegistrarMovimiento(objeto, out string mensaje);

                return Json(new { resultado = respuesta, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { resultado = false, mensaje = "Error: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }
    }
}
