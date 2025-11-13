using CapaDatos;
using CapaModelo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace VentasWeb.Controllers
{
    public class ListaPrecioController : Controller
    {
        // GET: ListaPrecio - Vista principal de listas de precios
        public ActionResult Index()
        {
            return View();
        }

        // GET: ListaPrecio/Detalle/{id} - Vista de detalle de una lista con sus productos
        public ActionResult Detalle(int id)
        {
            ViewBag.IdListaPrecio = id;
            return View();
        }

        // ===========================
        // API PARA LISTAS DE PRECIOS
        // ===========================

        // Obtener todas las listas de precios
        [HttpGet]
        public JsonResult ObtenerListasPrecios(int? idTienda = null)
        {
            try
            {
                List<ListaPrecio> lista = CD_ListaPrecio.Instancia.ObtenerListasPrecios(idTienda);
                return Json(new { success = true, data = lista }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, mensaje = "Error: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // Registrar nueva lista de precios
        [HttpPost]
        public JsonResult RegistrarListaPrecio(ListaPrecio oListaPrecio)
        {
            try
            {
                string mensaje;
                bool resultado = CD_ListaPrecio.Instancia.RegistrarListaPrecio(oListaPrecio, out mensaje);
                
                return Json(new { success = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, mensaje = "Error: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // Modificar lista de precios
        [HttpPost]
        public JsonResult ModificarListaPrecio(ListaPrecio oListaPrecio)
        {
            try
            {
                string mensaje;
                bool resultado = CD_ListaPrecio.Instancia.ModificarListaPrecio(oListaPrecio, out mensaje);
                
                return Json(new { success = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, mensaje = "Error: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // Eliminar lista de precios
        [HttpPost]
        public JsonResult EliminarListaPrecio(int IdListaPrecio)
        {
            try
            {
                string mensaje;
                bool resultado = CD_ListaPrecio.Instancia.EliminarListaPrecio(IdListaPrecio, out mensaje);
                
                return Json(new { success = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, mensaje = "Error: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // ===================================
        // API PARA PRODUCTOS EN LISTA PRECIO
        // ===================================

        // Obtener productos de una lista
        [HttpGet]
        public JsonResult ObtenerProductosListaPrecio(int idListaPrecio, bool soloVigentes = false)
        {
            try
            {
                List<ListaPrecioDetalle> lista = CD_ListaPrecio.Instancia.ObtenerProductosListaPrecio(idListaPrecio, soloVigentes);
                return Json(new { success = true, data = lista }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, mensaje = "Error: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // Agregar producto a lista de precios
        [HttpPost]
        public JsonResult AgregarProductoListaPrecio(ListaPrecioDetalle oDetalle)
        {
            try
            {
                string mensaje;
                bool resultado = CD_ListaPrecio.Instancia.AgregarProductoListaPrecio(oDetalle, out mensaje);
                
                return Json(new { success = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, mensaje = "Error: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // Modificar producto en lista de precios
        [HttpPost]
        public JsonResult ModificarProductoListaPrecio(ListaPrecioDetalle oDetalle)
        {
            try
            {
                string mensaje;
                bool resultado = CD_ListaPrecio.Instancia.ModificarProductoListaPrecio(oDetalle, out mensaje);
                
                return Json(new { success = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, mensaje = "Error: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // Eliminar producto de lista de precios
        [HttpPost]
        public JsonResult EliminarProductoListaPrecio(int idListaPrecioDetalle)
        {
            try
            {
                string mensaje;
                bool resultado = CD_ListaPrecio.Instancia.EliminarProductoListaPrecio(idListaPrecioDetalle, out mensaje);
                
                return Json(new { success = resultado, mensaje = mensaje }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, mensaje = "Error: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // Obtener precio vigente de un producto
        [HttpGet]
        public JsonResult ObtenerPrecioProductoVigente(int idListaPrecio, int idProducto, string fecha = null)
        {
            try
            {
                DateTime? fechaConsulta = null;
                if (!string.IsNullOrEmpty(fecha))
                {
                    fechaConsulta = DateTime.Parse(fecha);
                }

                ListaPrecioDetalle detalle = CD_ListaPrecio.Instancia.ObtenerPrecioProductoVigente(idListaPrecio, idProducto, fechaConsulta);
                
                if (detalle != null)
                {
                    return Json(new { success = true, data = detalle }, JsonRequestBehavior.AllowGet);
                }
                else
                {
                    return Json(new { success = false, mensaje = "No se encontró precio vigente para el producto" }, JsonRequestBehavior.AllowGet);
                }
            }
            catch (Exception ex)
            {
                return Json(new { success = false, mensaje = "Error: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // Obtener productos disponibles para agregar
        [HttpGet]
        public JsonResult ObtenerProductosDisponibles(int idListaPrecio, string fechaDesde, string fechaHasta)
        {
            try
            {
                DateTime desde = DateTime.Parse(fechaDesde);
                DateTime hasta = DateTime.Parse(fechaHasta);

                List<Producto> lista = CD_ListaPrecio.Instancia.ObtenerProductosDisponiblesParaLista(idListaPrecio, desde, hasta);
                return Json(new { success = true, data = lista }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, mensaje = "Error: " + ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // MÉTODOS PARA VENTAS

        [HttpGet]
        public JsonResult ObtenerListasPreciosActivas()
        {
            List<ListaPrecio> lista = CD_ListaPrecio.Instancia.ObtenerListasPrecios();
            // Filtrar solo listas activas
            lista = lista.Where(x => x.Activo).ToList();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpGet]
        public JsonResult ObtenerPrecioProductoVigente(int idListaPrecio, int idProducto)
        {
            try
            {
                ListaPrecioDetalle detalle = CD_ListaPrecio.Instancia.ObtenerPrecioProductoVigente(idListaPrecio, idProducto, DateTime.Now);
                
                if (detalle != null)
                {
                    return Json(new { resultado = true, precio = detalle.PrecioVenta }, JsonRequestBehavior.AllowGet);
                }
                else
                {
                    return Json(new { resultado = false, mensaje = "El producto no tiene precio vigente en esta lista" }, JsonRequestBehavior.AllowGet);
                }
            }
            catch (Exception ex)
            {
                return Json(new { resultado = false, mensaje = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // TEST: Método simple para verificar que la ruta funciona
        [HttpGet]
        public JsonResult TestEndpoint()
        {
            return Json(new { success = true, mensaje = "Endpoint funciona!" }, JsonRequestBehavior.AllowGet);
        }

        // Obtener productos de lista con stock de tienda para ventas
        [HttpGet]
        public JsonResult ObtenerProductosListaPrecioConStock(int idListaPrecio = 0, int idTienda = 0)
        {
            try
            {
                // Si no hay lista seleccionada, retornar vacío
                if (idListaPrecio == 0 || idTienda == 0)
                {
                    return Json(new { success = true, data = new List<object>() }, JsonRequestBehavior.AllowGet);
                }

                // Obtener productos de la lista de precios con precio vigente
                List<ListaPrecioDetalle> productosLista = CD_ListaPrecio.Instancia.ObtenerProductosListaPrecio(idListaPrecio, true); // Solo vigentes
                
                if (productosLista == null || productosLista.Count == 0)
                {
                    return Json(new { success = true, data = new List<object>(), mensaje = "La lista no tiene productos con precio vigente" }, JsonRequestBehavior.AllowGet);
                }
                
                // Obtener TODOS los productos-tienda (sin parámetro)
                List<ProductoTienda> todosProductosTienda = CD_ProductoTienda.Instancia.ObtenerProductoTienda();
                
                if (todosProductosTienda == null || todosProductosTienda.Count == 0)
                {
                    return Json(new { success = true, data = new List<object>(), mensaje = "No hay productos en las tiendas" }, JsonRequestBehavior.AllowGet);
                }
                
                // Filtrar por tienda específica
                var stockTienda = todosProductosTienda.Where(pt => pt.oTienda.IdTienda == idTienda).ToList();
                
                if (stockTienda.Count == 0)
                {
                    return Json(new { success = true, data = new List<object>(), mensaje = "No hay productos en esta tienda" }, JsonRequestBehavior.AllowGet);
                }
                
                // Combinar información: solo productos que están en la lista Y tienen stock en la tienda
                var resultado = (from pl in productosLista
                                join st in stockTienda on pl.IdProducto equals st.oProducto.IdProducto
                                where st.Stock > 0 // Solo productos con stock
                                select new
                                {
                                    IdProductoTienda = st.IdProductoTienda,
                                    oProducto = st.oProducto,
                                    Stock = st.Stock,
                                    PrecioVenta = pl.PrecioVenta
                                }).ToList();

                return Json(new { success = true, data = resultado }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(new { success = false, data = new List<object>(), error = ex.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        // Copiar lista desde otra con ajuste porcentual
        [HttpPost]
        public JsonResult CopiarListaConAjuste(ListaPrecio lista, int IdListaOrigen, decimal PorcentajeAjuste)
        {
            try
            {
                // Validar que lista no sea null
                if (lista == null)
                {
                    return Json(new { success = false, mensaje = "Datos de lista no válidos" });
                }
                
                string nombre = lista.Nombre;
                string descripcion = lista.Descripcion ?? string.Empty;
                string tipoLista = lista.TipoLista;
                int? idTienda = lista.IdTienda;
                bool activo = lista.Activo;
                int idListaOrigen = IdListaOrigen;
                decimal porcentajeAjuste = PorcentajeAjuste;
                
                // Validaciones
                if (string.IsNullOrEmpty(nombre))
                {
                    return Json(new { success = false, mensaje = "El nombre es requerido" });
                }
                
                if (string.IsNullOrEmpty(tipoLista))
                {
                    return Json(new { success = false, mensaje = "El tipo de lista es requerido" });
                }
                
                if (idListaOrigen <= 0)
                {
                    return Json(new { success = false, mensaje = "Debe seleccionar una lista de origen" });
                }

                // 1. Crear la nueva lista
                ListaPrecio nuevaLista = new ListaPrecio
                {
                    Nombre = nombre,
                    Descripcion = descripcion,
                    TipoLista = tipoLista,
                    IdTienda = idTienda,
                    Activo = activo
                };

                string mensajeCreacion = string.Empty;
                bool listaCreada = CD_ListaPrecio.Instancia.RegistrarListaPrecio(nuevaLista, out mensajeCreacion);

                if (!listaCreada)
                {
                    return Json(new { success = false, mensaje = mensajeCreacion });
                }

                // Obtener el ID de la lista recién creada
                List<ListaPrecio> listas = CD_ListaPrecio.Instancia.ObtenerListasPrecios();
                ListaPrecio listaCreada2 = listas.FirstOrDefault(x => x.Nombre == nombre);
                
                if (listaCreada2 == null)
                {
                    return Json(new { success = false, mensaje = "No se pudo obtener la lista creada" });
                }

                int idListaNueva = listaCreada2.IdListaPrecio;

                // 2. Obtener todos los productos de la lista origen
                List<ListaPrecioDetalle> productosOrigen = CD_ListaPrecio.Instancia.ObtenerProductosListaPrecio(idListaOrigen);

                if (productosOrigen == null)
                {
                    return Json(new { success = false, mensaje = "Error al obtener productos de la lista origen (null)" });
                }

                if (productosOrigen.Count == 0)
                {
                    return Json(new { success = false, mensaje = "La lista origen no tiene productos" });
                }

                int productosCopiados = 0;
                int productosEnOrigen = productosOrigen.Count;
                int productosErrores = 0;
                decimal multiplicador = 1 + (porcentajeAjuste / 100);
                List<string> errores = new List<string>();

                // 3. Copiar cada producto con precio ajustado
                foreach (var productoOrigen in productosOrigen)
                {
                    try
                    {
                        // Validar que el producto tenga ID valido
                        if (productoOrigen.IdProducto <= 0)
                        {
                            errores.Add("Producto con ID invalido: " + productoOrigen.IdProducto);
                            productosErrores++;
                            continue;
                        }

                        decimal nuevoPrecio = Math.Round(productoOrigen.PrecioVenta * multiplicador, 2);

                        ListaPrecioDetalle nuevoDetalle = new ListaPrecioDetalle
                        {
                            IdListaPrecio = idListaNueva,
                            IdProducto = productoOrigen.IdProducto,
                            PrecioVenta = nuevoPrecio,
                            FechaVigenciaDesde = productoOrigen.FechaVigenciaDesde,
                            FechaVigenciaHasta = productoOrigen.FechaVigenciaHasta,
                            Activo = productoOrigen.Activo
                        };

                        string mensajeProducto = string.Empty;
                        bool agregado = CD_ListaPrecio.Instancia.AgregarProductoListaPrecio(nuevoDetalle, out mensajeProducto);
                        
                        if (agregado)
                        {
                            productosCopiados++;
                        }
                        else
                        {
                            errores.Add("Producto ID " + productoOrigen.IdProducto + ": " + mensajeProducto);
                            productosErrores++;
                        }
                    }
                    catch (Exception exProducto)
                    {
                        errores.Add("Error en producto ID " + productoOrigen.IdProducto + ": " + exProducto.Message);
                        productosErrores++;
                    }
                }

                // Construir mensaje final
                string mensajeFinal = string.Format("Lista creada exitosamente. Productos en origen: {0}, productos copiados: {1}", 
                                                    productosEnOrigen, productosCopiados);
                
                if (productosErrores > 0)
                {
                    mensajeFinal += string.Format(", errores: {0}", productosErrores);
                }

                return Json(new
                {
                    success = productosCopiados > 0, // Solo exito si copio al menos 1 producto
                    mensaje = mensajeFinal,
                    productosCopiados = productosCopiados,
                    productosEnOrigen = productosEnOrigen,
                    productosErrores = productosErrores,
                    errores = errores,
                    idListaNueva = idListaNueva
                });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, mensaje = "Error: " + ex.Message });
            }
        }
    }
}
