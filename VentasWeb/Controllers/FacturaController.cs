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
        public JsonResult ActualizarEstado(int idFactura, string estado)
        {
            bool respuesta = CD_Factura.Instancia.ActualizarEstadoFactura(idFactura, estado);
            return Json(new { resultado = respuesta }, JsonRequestBehavior.AllowGet);
        }
    }
}
