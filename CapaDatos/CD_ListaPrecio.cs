using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaDatos
{
    public class CD_ListaPrecio
    {
        public static CD_ListaPrecio _instancia = null;

        private CD_ListaPrecio()
        {

        }

        public static CD_ListaPrecio Instancia
        {
            get
            {
                if (_instancia == null)
                {
                    _instancia = new CD_ListaPrecio();
                }
                return _instancia;
            }
        }

        // Obtener todas las listas de precios
        public List<ListaPrecio> ObtenerListasPrecios(int? IdTienda = null)
        {
            List<ListaPrecio> lista = new List<ListaPrecio>();
            
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_ObtenerListasPrecios", oConexion);
                    cmd.Parameters.AddWithValue("@IdTienda", (object)IdTienda ?? DBNull.Value);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new ListaPrecio()
                        {
                            IdListaPrecio = Convert.ToInt32(dr["IdListaPrecio"]),
                            Nombre = dr["Nombre"].ToString(),
                            Descripcion = dr["Descripcion"].ToString(),
                            TipoLista = dr["TipoLista"].ToString(),
                            IdTienda = dr["IdTienda"] == DBNull.Value ? (int?)null : Convert.ToInt32(dr["IdTienda"]),
                            oTienda = dr["NombreTienda"] != DBNull.Value ? new Tienda() { Nombre = dr["NombreTienda"].ToString() } : null,
                            Activo = Convert.ToBoolean(dr["Activo"]),
                            FechaRegistro = Convert.ToDateTime(dr["FechaRegistro"]),
                            CantidadProductos = Convert.ToInt32(dr["CantidadProductos"]),
                            ProductosVigentes = Convert.ToInt32(dr["ProductosVigentes"])
                        });
                    }
                    dr.Close();
                }
                catch (Exception ex)
                {
                    lista = new List<ListaPrecio>();
                }
            }

            return lista;
        }

        // Registrar nueva lista de precios
        public bool RegistrarListaPrecio(ListaPrecio oListaPrecio, out string Mensaje)
        {
            bool respuesta = false;
            Mensaje = string.Empty;

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_RegistrarListaPrecio", oConexion);
                    cmd.Parameters.AddWithValue("@Nombre", oListaPrecio.Nombre);
                    cmd.Parameters.AddWithValue("@Descripcion", oListaPrecio.Descripcion);
                    cmd.Parameters.AddWithValue("@TipoLista", oListaPrecio.TipoLista);
                    cmd.Parameters.AddWithValue("@IdTienda", (object)oListaPrecio.IdTienda ?? DBNull.Value);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    cmd.ExecuteNonQuery();

                    respuesta = Convert.ToBoolean(cmd.Parameters["@Resultado"].Value);
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
                catch (Exception ex)
                {
                    respuesta = false;
                    Mensaje = ex.Message;
                }
            }

            return respuesta;
        }

        // Modificar lista de precios existente
        public bool ModificarListaPrecio(ListaPrecio oListaPrecio, out string Mensaje)
        {
            bool respuesta = false;
            Mensaje = string.Empty;

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_ModificarListaPrecio", oConexion);
                    cmd.Parameters.AddWithValue("@IdListaPrecio", oListaPrecio.IdListaPrecio);
                    cmd.Parameters.AddWithValue("@Nombre", oListaPrecio.Nombre);
                    cmd.Parameters.AddWithValue("@Descripcion", oListaPrecio.Descripcion);
                    cmd.Parameters.AddWithValue("@TipoLista", oListaPrecio.TipoLista);
                    cmd.Parameters.AddWithValue("@Activo", oListaPrecio.Activo);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    cmd.ExecuteNonQuery();

                    respuesta = Convert.ToBoolean(cmd.Parameters["@Resultado"].Value);
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
                catch (Exception ex)
                {
                    respuesta = false;
                    Mensaje = ex.Message;
                }
            }

            return respuesta;
        }

        // Eliminar lista de precios (borrado fisico)
        public bool EliminarListaPrecio(int IdListaPrecio, out string Mensaje)
        {
            bool respuesta = false;
            Mensaje = string.Empty;

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_EliminarListaPrecio", oConexion);
                    cmd.Parameters.AddWithValue("@IdListaPrecio", IdListaPrecio);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    cmd.ExecuteNonQuery();

                    respuesta = Convert.ToBoolean(cmd.Parameters["@Resultado"].Value);
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
                catch (Exception ex)
                {
                    respuesta = false;
                    Mensaje = ex.Message;
                }
            }

            return respuesta;
        }

        // Obtener productos de una lista de precios
        public List<ListaPrecioDetalle> ObtenerProductosListaPrecio(int IdListaPrecio, bool SoloVigentes = false)
        {
            List<ListaPrecioDetalle> lista = new List<ListaPrecioDetalle>();

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_ObtenerProductosListaPrecio", oConexion);
                    cmd.Parameters.AddWithValue("@IdListaPrecio", IdListaPrecio);
                    cmd.Parameters.AddWithValue("@SoloVigentes", SoloVigentes);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new ListaPrecioDetalle()
                        {
                            IdListaPrecioDetalle = Convert.ToInt32(dr["IdListaPrecioDetalle"]),
                            IdListaPrecio = Convert.ToInt32(dr["IdListaPrecio"]),
                            IdProducto = Convert.ToInt32(dr["IdProducto"]),
                            oProducto = new Producto()
                            {
                                Codigo = dr["Codigo"].ToString(),
                                Nombre = dr["NombreProducto"].ToString(),
                                Descripcion = dr["DescripcionProducto"].ToString()
                            },
                            Categoria = dr["Categoria"].ToString(),
                            PrecioVenta = Convert.ToDecimal(dr["PrecioVenta"]),
                            FechaVigenciaDesde = Convert.ToDateTime(dr["FechaVigenciaDesde"]),
                            FechaVigenciaHasta = Convert.ToDateTime(dr["FechaVigenciaHasta"]),
                            Activo = Convert.ToBoolean(dr["Activo"]),
                            FechaRegistro = Convert.ToDateTime(dr["FechaRegistro"]),
                            EsVigente = Convert.ToBoolean(dr["EsVigente"])
                        });
                    }
                    dr.Close();
                }
                catch (Exception ex)
                {
                    lista = new List<ListaPrecioDetalle>();
                }
            }

            return lista;
        }

        // Agregar producto a lista de precios
        public bool AgregarProductoListaPrecio(ListaPrecioDetalle oDetalle, out string Mensaje)
        {
            bool respuesta = false;
            Mensaje = string.Empty;

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_AgregarProductoListaPrecio", oConexion);
                    cmd.Parameters.AddWithValue("@IdListaPrecio", oDetalle.IdListaPrecio);
                    cmd.Parameters.AddWithValue("@IdProducto", oDetalle.IdProducto);
                    cmd.Parameters.AddWithValue("@PrecioVenta", oDetalle.PrecioVenta);
                    cmd.Parameters.AddWithValue("@FechaVigenciaDesde", oDetalle.FechaVigenciaDesde.Date);
                    cmd.Parameters.AddWithValue("@FechaVigenciaHasta", oDetalle.FechaVigenciaHasta.Date);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    cmd.ExecuteNonQuery();

                    respuesta = Convert.ToBoolean(cmd.Parameters["@Resultado"].Value);
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
                catch (Exception ex)
                {
                    respuesta = false;
                    Mensaje = ex.Message;
                }
            }

            return respuesta;
        }

        // Modificar producto en lista de precios
        public bool ModificarProductoListaPrecio(ListaPrecioDetalle oDetalle, out string Mensaje)
        {
            bool respuesta = false;
            Mensaje = string.Empty;

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_ModificarProductoListaPrecio", oConexion);
                    cmd.Parameters.AddWithValue("@IdListaPrecioDetalle", oDetalle.IdListaPrecioDetalle);
                    cmd.Parameters.AddWithValue("@PrecioVenta", oDetalle.PrecioVenta);
                    cmd.Parameters.AddWithValue("@FechaVigenciaDesde", oDetalle.FechaVigenciaDesde.Date);
                    cmd.Parameters.AddWithValue("@FechaVigenciaHasta", oDetalle.FechaVigenciaHasta.Date);
                    cmd.Parameters.AddWithValue("@Activo", oDetalle.Activo);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    cmd.ExecuteNonQuery();

                    respuesta = Convert.ToBoolean(cmd.Parameters["@Resultado"].Value);
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
                catch (Exception ex)
                {
                    respuesta = false;
                    Mensaje = ex.Message;
                }
            }

            return respuesta;
        }

        // Eliminar producto de lista de precios
        public bool EliminarProductoListaPrecio(int IdListaPrecioDetalle, out string Mensaje)
        {
            bool respuesta = false;
            Mensaje = string.Empty;

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_EliminarProductoListaPrecio", oConexion);
                    cmd.Parameters.AddWithValue("@IdListaPrecioDetalle", IdListaPrecioDetalle);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    cmd.ExecuteNonQuery();

                    respuesta = Convert.ToBoolean(cmd.Parameters["@Resultado"].Value);
                    Mensaje = cmd.Parameters["@Mensaje"].Value.ToString();
                }
                catch (Exception ex)
                {
                    respuesta = false;
                    Mensaje = ex.Message;
                }
            }

            return respuesta;
        }

        // Obtener precio vigente de un producto según lista
        public ListaPrecioDetalle ObtenerPrecioProductoVigente(int IdListaPrecio, int IdProducto, DateTime? Fecha = null)
        {
            ListaPrecioDetalle detalle = null;

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_ObtenerPrecioProductoVigente", oConexion);
                    cmd.Parameters.AddWithValue("@IdListaPrecio", IdListaPrecio);
                    cmd.Parameters.AddWithValue("@IdProducto", IdProducto);
                    cmd.Parameters.AddWithValue("@Fecha", (object)Fecha ?? DBNull.Value);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        detalle = new ListaPrecioDetalle()
                        {
                            IdListaPrecioDetalle = Convert.ToInt32(dr["IdListaPrecioDetalle"]),
                            IdListaPrecio = Convert.ToInt32(dr["IdListaPrecio"]),
                            oListaPrecio = new ListaPrecio()
                            {
                                Nombre = dr["NombreLista"].ToString(),
                                TipoLista = dr["TipoLista"].ToString()
                            },
                            IdProducto = Convert.ToInt32(dr["IdProducto"]),
                            oProducto = new Producto()
                            {
                                Nombre = dr["NombreProducto"].ToString()
                            },
                            PrecioVenta = Convert.ToDecimal(dr["PrecioVenta"]),
                            FechaVigenciaDesde = Convert.ToDateTime(dr["FechaVigenciaDesde"]),
                            FechaVigenciaHasta = Convert.ToDateTime(dr["FechaVigenciaHasta"])
                        };
                    }
                    dr.Close();
                }
                catch (Exception ex)
                {
                    detalle = null;
                }
            }

            return detalle;
        }

        // Obtener productos disponibles para agregar a una lista
        public List<Producto> ObtenerProductosDisponiblesParaLista(int IdListaPrecio, DateTime FechaDesde, DateTime FechaHasta)
        {
            List<Producto> lista = new List<Producto>();

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_ObtenerProductosDisponiblesParaLista", oConexion);
                    cmd.Parameters.AddWithValue("@IdListaPrecio", IdListaPrecio);
                    cmd.Parameters.AddWithValue("@FechaDesde", FechaDesde.Date);
                    cmd.Parameters.AddWithValue("@FechaHasta", FechaHasta.Date);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new Producto()
                        {
                            IdProducto = Convert.ToInt32(dr["IdProducto"]),
                            Codigo = dr["Codigo"].ToString(),
                            Nombre = dr["Nombre"].ToString(),
                            Descripcion = dr["Descripcion"].ToString(),
                            oCategoria = new Categoria() { Descripcion = dr["Categoria"].ToString() },
                            Activo = Convert.ToBoolean(dr["Activo"])
                        });
                    }
                    dr.Close();
                }
                catch (Exception ex)
                {
                    lista = new List<Producto>();
                }
            }

            return lista;
        }
    }
}
