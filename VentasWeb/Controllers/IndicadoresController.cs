using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using CapaDatos;
using CapaModelo;

namespace VentasWeb.Controllers
{
    public class IndicadoresController : Controller
    {
        // GET: Indicadores
        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public JsonResult ObtenerResumenGeneral(string fechaInicio, string fechaFin)
        {
            try
            {
                DateTime dtInicio = DateTime.ParseExact(fechaInicio, "dd/MM/yyyy", null);
                DateTime dtFin = DateTime.ParseExact(fechaFin, "dd/MM/yyyy", null);

                var resumen = CD_Indicadores.Instancia.ObtenerResumenGeneral(dtInicio, dtFin);

                return Json(new { data = resumen }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult ObtenerVentasPorTienda(string fechaInicio, string fechaFin)
        {
            try
            {
                DateTime dtInicio = DateTime.ParseExact(fechaInicio, "dd/MM/yyyy", null);
                DateTime dtFin = DateTime.ParseExact(fechaFin, "dd/MM/yyyy", null);

                var datos = CD_Indicadores.Instancia.ObtenerVentasPorTienda(dtInicio, dtFin);

                return Json(new { data = datos }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult ObtenerVentasPorTipoDocumento(string fechaInicio, string fechaFin)
        {
            try
            {
                DateTime dtInicio = DateTime.ParseExact(fechaInicio, "dd/MM/yyyy", null);
                DateTime dtFin = DateTime.ParseExact(fechaFin, "dd/MM/yyyy", null);

                var datos = CD_Indicadores.Instancia.ObtenerVentasPorTipoDocumento(dtInicio, dtFin);

                return Json(new { data = datos }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult ObtenerVentasPorMetodoPago(string fechaInicio, string fechaFin)
        {
            try
            {
                DateTime dtInicio = DateTime.ParseExact(fechaInicio, "dd/MM/yyyy", null);
                DateTime dtFin = DateTime.ParseExact(fechaFin, "dd/MM/yyyy", null);

                var datos = CD_Indicadores.Instancia.ObtenerVentasPorMetodoPago(dtInicio, dtFin);

                return Json(new { data = datos }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult ObtenerTopClientes(string fechaInicio, string fechaFin)
        {
            try
            {
                DateTime dtInicio = DateTime.ParseExact(fechaInicio, "dd/MM/yyyy", null);
                DateTime dtFin = DateTime.ParseExact(fechaFin, "dd/MM/yyyy", null);

                var datos = CD_Indicadores.Instancia.ObtenerTopClientes(dtInicio, dtFin, 10);

                return Json(new { data = datos }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult ObtenerTopProductos(string fechaInicio, string fechaFin)
        {
            try
            {
                DateTime dtInicio = DateTime.ParseExact(fechaInicio, "dd/MM/yyyy", null);
                DateTime dtFin = DateTime.ParseExact(fechaFin, "dd/MM/yyyy", null);

                var datos = CD_Indicadores.Instancia.ObtenerTopProductos(dtInicio, dtFin, 10);

                return Json(new { data = datos }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult ObtenerVentasPorDia(string fechaInicio, string fechaFin)
        {
            try
            {
                DateTime dtInicio = DateTime.ParseExact(fechaInicio, "dd/MM/yyyy", null);
                DateTime dtFin = DateTime.ParseExact(fechaFin, "dd/MM/yyyy", null);

                var datos = CD_Indicadores.Instancia.ObtenerVentasPorDia(dtInicio, dtFin);

                // Formatear fechas como string para evitar problemas de serialización
                var datosFormateados = datos.Select(x => new
                {
                    Fecha = x.Fecha.ToString("dd/MM/yyyy"),
                    CantidadVentas = x.CantidadVentas,
                    TotalVendido = x.TotalVendido
                }).ToList();

                return Json(new { data = datosFormateados }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult ObtenerComprasPorProveedor(string fechaInicio, string fechaFin)
        {
            try
            {
                DateTime dtInicio = DateTime.ParseExact(fechaInicio, "dd/MM/yyyy", null);
                DateTime dtFin = DateTime.ParseExact(fechaFin, "dd/MM/yyyy", null);

                var datos = CD_Indicadores.Instancia.ObtenerComprasPorProveedor(dtInicio, dtFin);

                return Json(new { data = datos }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult ObtenerComprasPorDia(string fechaInicio, string fechaFin)
        {
            try
            {
                DateTime dtInicio = DateTime.ParseExact(fechaInicio, "dd/MM/yyyy", null);
                DateTime dtFin = DateTime.ParseExact(fechaFin, "dd/MM/yyyy", null);

                var datos = CD_Indicadores.Instancia.ObtenerComprasPorDia(dtInicio, dtFin);

                // Formatear fechas como string para evitar problemas de serialización
                var datosFormateados = datos.Select(x => new
                {
                    Fecha = x.Fecha.ToString("dd/MM/yyyy"),
                    CantidadCompras = x.CantidadCompras,
                    TotalComprado = x.TotalComprado
                }).ToList();

                return Json(new { data = datosFormateados }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult ObtenerTopProductosComprados(string fechaInicio, string fechaFin)
        {
            try
            {
                DateTime dtInicio = DateTime.ParseExact(fechaInicio, "dd/MM/yyyy", null);
                DateTime dtFin = DateTime.ParseExact(fechaFin, "dd/MM/yyyy", null);

                var datos = CD_Indicadores.Instancia.ObtenerTopProductosComprados(dtInicio, dtFin, 10);

                return Json(new { data = datos }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult ObtenerTopProveedores(string fechaInicio, string fechaFin)
        {
            try
            {
                DateTime dtInicio = DateTime.ParseExact(fechaInicio, "dd/MM/yyyy", null);
                DateTime dtFin = DateTime.ParseExact(fechaFin, "dd/MM/yyyy", null);

                var datos = CD_Indicadores.Instancia.ObtenerTopProveedores(dtInicio, dtFin, 10);

                return Json(new { data = datos }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }
    }
}
