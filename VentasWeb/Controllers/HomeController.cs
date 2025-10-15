using CapaModelo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace VentasWeb.Controllers
{
    public class HomeController : Controller
    {
        private static Usuario SesionUsuario;
        public ActionResult Index()
        {
            if (Session["Usuario"] != null)
                SesionUsuario = (Usuario)Session["Usuario"];
            else {
                SesionUsuario = new Usuario();
            }
            try
            {
                ViewBag.NombreUsuario = SesionUsuario.Nombres + " " + SesionUsuario.Apellidos;
                if (SesionUsuario.oRol != null)
                    ViewBag.RolUsuario = SesionUsuario.oRol.Descripcion;
                else
                    ViewBag.RolUsuario = "Sin rol";

            }
            catch {

            }

           
            return View();
        }

        public ActionResult Salir()
        {
            Session["Usuario"] = null;
            return RedirectToAction("Index", "Login");
        }

    }
}