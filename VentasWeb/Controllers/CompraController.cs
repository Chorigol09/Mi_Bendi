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

            if (oCompra == null) {
                oCompra = new Compra();
            }


            return View(oCompra);
        }


        public JsonResult Obtener(string fechainicio, string fechafin, int idproveedor, int idtienda)
        {
            List<Compra> lista = CD_Compra.Instancia.ObtenerListaCompra(Convert.ToDateTime(fechainicio), Convert.ToDateTime(fechafin), idproveedor, idtienda);
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
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