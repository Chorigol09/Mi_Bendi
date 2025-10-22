using CapaDatos;
using CapaModelo;
using System;
using System.Collections.Generic;
using System.Web.Mvc;

namespace VentasWeb.Controllers
{
    public class FacturaController : Controller
    {
        [HttpGet]
        public ActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public ActionResult Crear()
        {
            return View();
        }

        [HttpGet]
        public ActionResult Consultar()
        {
            return View();
        }

        [HttpGet]
        public JsonResult Obtener()
        {
            List<Factura> lista = CD_Factura.Instancia.ObtenerFacturas();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult Guardar(Factura objeto)
        {
            bool respuesta = CD_Factura.Instancia.RegistrarFactura(objeto);
            return Json(new { resultado = respuesta }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        [ValidateInput(false)]
        public JsonResult GuardarConDetalles(string xml)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("XML recibido: " + xml);
                
                if (string.IsNullOrEmpty(xml))
                {
                    System.Diagnostics.Debug.WriteLine("ERROR: XML está vacío");
                    return Json(new { resultado = false, mensaje = "XML vacío" }, JsonRequestBehavior.AllowGet);
                }
                
                bool respuesta = CD_Factura.Instancia.RegistrarFacturaConDetalles(xml);
                System.Diagnostics.Debug.WriteLine("Resultado: " + respuesta);
                
                return Json(new { resultado = respuesta }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ERROR en GuardarConDetalles: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("StackTrace: " + ex.StackTrace);
                return Json(new { resultado = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult ActualizarEstado(int idFactura, string estado)
        {
            bool respuesta = CD_Factura.Instancia.ActualizarEstadoFactura(idFactura, estado);
            return Json(new { resultado = respuesta }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public ActionResult Documento(int idfactura)
        {
            Factura objeto = CD_Factura.Instancia.ObtenerFactura(idfactura);
            return View(objeto);
        }
    }
}
