using CapaDatos;
using CapaModelo;
using System;
using System.Web.Mvc;
using VentasWeb.Utilidades;

namespace VentasWeb.Controllers
{
    public class LoginController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Index(string correo, string clave)
        {
            if (string.IsNullOrWhiteSpace(correo) || string.IsNullOrWhiteSpace(clave))
            {
                ViewBag.Error = "Debes ingresar correo y contraseña.";
                return View();
            }

            // 1) Intento con la clave TAL CUAL (por si tu SP/BD guarda la clave en texto plano
            //    o el SP se encarga de hashearla internamente).
            Usuario usuario = CD_Usuario.Instancia.Autenticar(correo, clave);

            // 2) Si no encontró, intento con la clave HASHEADA en SHA256 (por si la BD guarda hash).
            if (usuario == null)
            {
                string claveHash = VentasWeb.Utilidades.Encriptar.GetSHA256(clave);
                usuario = CD_Usuario.Instancia.Autenticar(correo, claveHash);
            }

            // 3) Si aún no, último fallback comparando contra la lista (por si tu SP falla o retorna 0).
            if (usuario == null)
            {
                var lista = CapaDatos.CD_Usuario.Instancia.ObtenerUsuarios() ?? new System.Collections.Generic.List<CapaModelo.Usuario>();
                string claveHash = VentasWeb.Utilidades.Encriptar.GetSHA256(clave);
                usuario = lista.Find(u =>
                    u != null &&
                    u.Correo != null &&
                    u.Clave != null &&
                    u.Correo.Equals(correo, StringComparison.OrdinalIgnoreCase) &&
                    (u.Clave == clave || u.Clave == claveHash)
                );
                // si encontró por lista y tenés detalle por SP, lo cargo:
                if (usuario != null)
                {
                    var det = CapaDatos.CD_Usuario.Instancia.ObtenerDetalleUsuario(usuario.IdUsuario);
                    if (det != null) usuario = det;
                }
            }

            if (usuario == null)
            {
                ViewBag.Error = "Usuario o contraseña no correcta";
                return View();
            }

            Session["Usuario"] = usuario;
            return RedirectToAction("Index", "Home");
        }

    }
}
