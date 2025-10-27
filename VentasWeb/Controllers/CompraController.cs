using CapaDatos;
using CapaModelo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace VentasWeb.Controllers
{
    public class CompraController : Controller
    {
        // GET: Compra
        public ActionResult Crear()
        {
            return View();
        }
        // GET: Compra
        public ActionResult Consultar()
        {
            return View();
        }

        public ActionResult Documento(int idcompra = 0) {
            
            Compra oCompra = CD_Compra.Instancia.ObtenerDetalleCompra(idcompra);

            // Configurar formato: $X.XXX,XX (punto para miles, coma para decimales)
            System.Globalization.NumberFormatInfo formato = new System.Globalization.CultureInfo("es-AR").NumberFormat;
            formato.NumberGroupSeparator = ".";
            formato.NumberDecimalSeparator = ",";
            formato.NumberDecimalDigits = 2;

            if (oCompra == null) {
                oCompra = new Compra();
            } else {
                // Formatear el total
                oCompra.TextoTotalCosto = "$" + oCompra.TotalCosto.ToString("N", formato);
                
                // Formatear los detalles
                if (oCompra.oListaDetalleCompra != null) {
                    oCompra.oListaDetalleCompra = (from dc in oCompra.oListaDetalleCompra
                                                   select new DetalleCompra()
                                                   {
                                                       IdDetalleCompra = dc.IdDetalleCompra,
                                                       IdCompra = dc.IdCompra,
                                                       oProducto = dc.oProducto,
                                                       Cantidad = dc.Cantidad,
                                                       PrecioUnitarioCompra = dc.PrecioUnitarioCompra,
                                                       TextoPrecioUnitarioCompra = "$" + dc.PrecioUnitarioCompra.ToString("N", formato),
                                                       PrecioUnitarioVenta = dc.PrecioUnitarioVenta,
                                                       TotalCosto = dc.TotalCosto,
                                                       TextoTotalCosto = "$" + dc.TotalCosto.ToString("N", formato),
                                                       Activo = dc.Activo,
                                                       FechaRegistro = dc.FechaRegistro
                                                   }).ToList();
                }
            }

            return View(oCompra);
        }


        public JsonResult Obtener(string fechainicio, string fechafin, int idproveedor, int idtienda)
        {
            try
            {
                // Parsear fechas en formato dd/MM/yyyy (español)
                System.Globalization.CultureInfo culture = new System.Globalization.CultureInfo("es-AR");
                DateTime dtInicio = DateTime.ParseExact(fechainicio, "dd/MM/yyyy", culture);
                DateTime dtFin = DateTime.ParseExact(fechafin, "dd/MM/yyyy", culture);
                
                List<Compra> lista = CD_Compra.Instancia.ObtenerListaCompra(dtInicio, dtFin, idproveedor, idtienda);
                return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                // En caso de error, devolver lista vacía y registrar el error
                System.Diagnostics.Debug.WriteLine("Error al obtener compras: " + ex.Message);
                return Json(new { data = new List<Compra>() }, JsonRequestBehavior.AllowGet);
            }
        }


        [HttpPost]
        [ValidateInput(false)]
        public JsonResult Guardar(string xml)
        {
            // Obtener usuario de la sesión actual
            Usuario SesionUsuario = (Usuario)Session["Usuario"];
            
            if (SesionUsuario == null)
            {
                return Json(new { resultado = false, mensaje = "Sesión expirada" }, JsonRequestBehavior.AllowGet);
            }

            xml = xml.Replace("!idusuario¡", SesionUsuario.IdUsuario.ToString());

            bool respuesta = CD_Compra.Instancia.RegistrarCompra(xml);

            return Json(new { resultado = respuesta }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult ActualizarEstado(int idCompra, string estado)
        {
            bool respuesta = CD_Compra.Instancia.ActualizarEstadoOrdenCompra(idCompra, estado);
            return Json(new { resultado = respuesta }, JsonRequestBehavior.AllowGet);
        }


    }
}