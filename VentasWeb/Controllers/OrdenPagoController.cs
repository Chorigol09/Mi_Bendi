using CapaDatos;
using CapaModelo;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.Linq;
using System.Web.Mvc;

namespace VentasWeb.Controllers
{
    public class OrdenPagoController : Controller
    {
        // GET: OrdenPago/Registrar
        public ActionResult Registrar()
        {
            if (Session["Usuario"] == null)
                return RedirectToAction("Index", "Login");
            
            return View();
        }

        // GET: OrdenPago/Consultar
        public ActionResult Consultar()
        {
            if (Session["Usuario"] == null)
                return RedirectToAction("Index", "Login");
            
            return View();
        }

        #region MÉTODOS API

        [HttpGet]
        public JsonResult ObtenerProveedores()
        {
            List<Proveedor> oLista = new List<Proveedor>();
            oLista = CD_Proveedor.Instancia.ObtenerProveedor();

            return Json(new { data = oLista }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult ObtenerFacturasPendientes(int idProveedor)
        {
            try
            {
                List<Factura> oLista = new List<Factura>();
                oLista = CD_OrdenPago.Instancia.ObtenerFacturasPendientes(idProveedor);

                return Json(new { resultado = true, data = oLista, mensaje = "" }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { resultado = false, data = new List<Factura>(), mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult RegistrarOrdenPago(OrdenPago objeto)
        {
            object resultado;
            string mensaje = string.Empty;
            int idOrdenPago = 0;

            try
            {
                // Asignar usuario logueado
                Usuario oUsuario = (Usuario)Session["Usuario"];
                objeto.UsuarioRegistro = oUsuario.Nombres + " " + oUsuario.Apellidos;

                bool respuesta = CD_OrdenPago.Instancia.RegistrarOrdenPago(objeto, out mensaje, out idOrdenPago);

                resultado = new
                {
                    resultado = respuesta,
                    mensaje = respuesta ? "Orden de Pago registrada correctamente" : mensaje,
                    idOrdenPago = idOrdenPago
                };
            }
            catch (Exception ex)
            {
                resultado = new { resultado = false, mensaje = "Error: " + ex.Message };
            }

            return Json(resultado, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult ObtenerOrdenesPago(int? idProveedor = null)
        {
            try
            {
                List<OrdenPago> oLista = new List<OrdenPago>();
                oLista = CD_OrdenPago.Instancia.ObtenerOrdenesPago(idProveedor);

                return Json(new { resultado = true, data = oLista, mensaje = "" }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { resultado = false, data = new List<OrdenPago>(), mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult ObtenerDetalleOrdenPago(int idOrdenPago)
        {
            try
            {
                OrdenPago objeto = new OrdenPago();
                objeto = CD_OrdenPago.Instancia.ObtenerDetalleOrdenPago(idOrdenPago);

                return Json(new { resultado = true, data = objeto, mensaje = "" }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { resultado = false, data = new OrdenPago(), mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult ObtenerFacturasOrdenPago(int idOrdenPago)
        {
            try
            {
                List<FacturaOrdenPago> oLista = new List<FacturaOrdenPago>();
                oLista = CD_OrdenPago.Instancia.ObtenerFacturasOrdenPago(idOrdenPago);

                return Json(new { resultado = true, data = oLista, mensaje = "" }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { resultado = false, data = new List<FacturaOrdenPago>(), mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        #endregion
    }
}
