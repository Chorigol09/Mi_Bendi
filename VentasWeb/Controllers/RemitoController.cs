using CapaDatos;
using CapaModelo;
using System;
using System.Collections.Generic;
using System.Web.Mvc;

namespace VentasWeb.Controllers
{
    public class RemitoController : Controller
    {
        [HttpGet]
        public ActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public JsonResult Obtener()
        {
            List<Remito> lista = CD_Remito.Instancia.ObtenerRemitos();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult Guardar(Remito objeto)
        {
            bool respuesta = CD_Remito.Instancia.RegistrarRemito(objeto);
            return Json(new { resultado = respuesta }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult ActualizarEstado(int idRemito, string estado)
        {
            bool respuesta = CD_Remito.Instancia.ActualizarEstadoRemito(idRemito, estado);
            return Json(new { resultado = respuesta }, JsonRequestBehavior.AllowGet);
        }
    }
}
