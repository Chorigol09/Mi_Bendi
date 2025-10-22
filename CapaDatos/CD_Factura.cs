using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text;

namespace CapaDatos
{
    public class CD_Factura
    {
        public static CD_Factura _instancia = null;

        private CD_Factura()
        {
        }

        public static CD_Factura Instancia
        {
            get
            {
                if (_instancia == null)
                {
                    _instancia = new CD_Factura();
                }
                return _instancia;
            }
        }

        public List<Factura> ObtenerFacturas()
        {
            List<Factura> lista = new List<Factura>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_ObtenerFacturas", oConexion);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new Factura()
                        {
                            IdFactura = Convert.ToInt32(dr["IdFactura"]),
                            oProveedor = new Proveedor()
                            {
                                IdProveedor = Convert.ToInt32(dr["IdProveedor"]),
                                RazonSocial = dr["RazonSocial"].ToString()
                            },
                            NumeroFactura = dr["NumeroFactura"].ToString(),
                            Total = Convert.ToDecimal(dr["Total"], new CultureInfo("es-PE")),
                            Estado = dr["Estado"].ToString(),
                            Observaciones = dr["Observaciones"].ToString(),
                            Activo = Convert.ToBoolean(dr["Activo"]),
                            FechaEmision = Convert.ToDateTime(dr["FechaEmision"]),
                            FechaPago = dr["FechaPago"] != DBNull.Value ? Convert.ToDateTime(dr["FechaPago"]) : (DateTime?)null,
                            FechaOrdenCompra = dr["FechaOrdenCompra"] != DBNull.Value ? dr["FechaOrdenCompra"].ToString() : "",
                            CantidadProductos = dr["CantidadProductos"] != DBNull.Value ? Convert.ToInt32(dr["CantidadProductos"]) : 0,
                            Productos = dr["Productos"] != DBNull.Value ? dr["Productos"].ToString() : ""
                        });
                    }
                    dr.Close();
                }
                catch (Exception ex)
                {
                    lista = new List<Factura>();
                }
            }
            return lista;
        }

        public bool RegistrarFactura(Factura factura)
        {
            bool respuesta = false;
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_RegistrarFactura", oConexion);
                    cmd.Parameters.AddWithValue("@IdOrdenCompra", factura.IdOrdenCompra);
                    cmd.Parameters.AddWithValue("@IdProveedor", factura.oProveedor.IdProveedor);
                    cmd.Parameters.AddWithValue("@NumeroFactura", factura.NumeroFactura);
                    cmd.Parameters.AddWithValue("@Total", factura.Total);
                    cmd.Parameters.AddWithValue("@Observaciones", factura.Observaciones ?? "");
                    cmd.Parameters.Add("@Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    cmd.ExecuteNonQuery();
                    respuesta = Convert.ToBoolean(cmd.Parameters["@Resultado"].Value);
                }
                catch (Exception ex)
                {
                    respuesta = false;
                }
            }
            return respuesta;
        }

        public bool ActualizarEstadoFactura(int idFactura, string estado)
        {
            bool respuesta = false;
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_ActualizarEstadoFactura", oConexion);
                    cmd.Parameters.AddWithValue("@IdFactura", idFactura);
                    cmd.Parameters.AddWithValue("@Estado", estado);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    cmd.ExecuteNonQuery();
                    respuesta = Convert.ToBoolean(cmd.Parameters["@Resultado"].Value);
                }
                catch (Exception ex)
                {
                    respuesta = false;
                }
            }
            return respuesta;
        }

        public bool RegistrarFacturaConDetalles(string xml)
        {
            bool respuesta = false;
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    System.Diagnostics.Debug.WriteLine("CD_Factura - Iniciando registro con XML: " + xml);
                    
                    SqlCommand cmd = new SqlCommand("usp_RegistrarFacturaConDetalles", oConexion);
                    cmd.Parameters.AddWithValue("@XML", xml);
                    cmd.Parameters.Add("@Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 60; // 60 segundos timeout

                    oConexion.Open();
                    System.Diagnostics.Debug.WriteLine("CD_Factura - Conexión abierta, ejecutando SP...");
                    
                    cmd.ExecuteNonQuery();
                    respuesta = Convert.ToBoolean(cmd.Parameters["@Resultado"].Value);
                    
                    System.Diagnostics.Debug.WriteLine("CD_Factura - Resultado del SP: " + respuesta);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("CD_Factura - ERROR: " + ex.Message);
                    System.Diagnostics.Debug.WriteLine("CD_Factura - StackTrace: " + ex.StackTrace);
                    if (ex.InnerException != null)
                    {
                        System.Diagnostics.Debug.WriteLine("CD_Factura - InnerException: " + ex.InnerException.Message);
                    }
                    respuesta = false;
                    throw; // Re-lanzar la excepción para que el controlador la capture
                }
            }
            return respuesta;
        }

        public Factura ObtenerFactura(int idFactura)
        {
            Factura objeto = new Factura();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    StringBuilder query = new StringBuilder();
                    query.AppendLine("SELECT f.IdFactura, f.IdProveedor, f.NumeroFactura, f.FechaEmision, f.Total, f.Estado,");
                    query.AppendLine("p.Ruc, p.RazonSocial");
                    query.AppendLine("FROM FACTURA f");
                    query.AppendLine("INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor");
                    query.AppendLine("WHERE f.IdFactura = @IdFactura");

                    SqlCommand cmd = new SqlCommand(query.ToString(), oConexion);
                    cmd.Parameters.AddWithValue("@IdFactura", idFactura);
                    cmd.CommandType = CommandType.Text;

                    oConexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            objeto = new Factura()
                            {
                                IdFactura = Convert.ToInt32(dr["IdFactura"]),
                                IdProveedor = Convert.ToInt32(dr["IdProveedor"]),
                                NumeroFactura = dr["NumeroFactura"].ToString(),
                                FechaEmision = Convert.ToDateTime(dr["FechaEmision"]),
                                TextoFechaEmision = Convert.ToDateTime(dr["FechaEmision"]).ToString("dd/MM/yyyy"),
                                Total = Convert.ToDecimal(dr["Total"], new CultureInfo("es-PE")),
                                TextoTotal = Convert.ToDecimal(dr["Total"], new CultureInfo("es-PE")).ToString("C", new CultureInfo("es-AR")),
                                Estado = dr["Estado"].ToString(),
                                oProveedor = new Proveedor()
                                {
                                    IdProveedor = Convert.ToInt32(dr["IdProveedor"]),
                                    Ruc = dr["Ruc"].ToString(),
                                    RazonSocial = dr["RazonSocial"].ToString()
                                }
                            };
                        }
                    }

                    // Obtener detalles
                    if (objeto.IdFactura != 0)
                    {
                        StringBuilder queryDetalle = new StringBuilder();
                        queryDetalle.AppendLine("SELECT df.IdDetalleFactura, df.IdProducto, df.Cantidad, df.PrecioUnitario, df.Subtotal,");
                        queryDetalle.AppendLine("pr.Codigo, pr.Nombre");
                        queryDetalle.AppendLine("FROM DETALLE_FACTURA df");
                        queryDetalle.AppendLine("INNER JOIN PRODUCTO pr ON df.IdProducto = pr.IdProducto");
                        queryDetalle.AppendLine("WHERE df.IdFactura = @IdFactura AND df.Activo = 1");

                        SqlCommand cmdDetalle = new SqlCommand(queryDetalle.ToString(), oConexion);
                        cmdDetalle.Parameters.AddWithValue("@IdFactura", idFactura);
                        cmdDetalle.CommandType = CommandType.Text;

                        objeto.oListaDetalleFactura = new List<DetalleFactura>();

                        using (SqlDataReader drDetalle = cmdDetalle.ExecuteReader())
                        {
                            while (drDetalle.Read())
                            {
                                objeto.oListaDetalleFactura.Add(new DetalleFactura()
                                {
                                    IdDetalleFactura = Convert.ToInt32(drDetalle["IdDetalleFactura"]),
                                    oProducto = new Producto()
                                    {
                                        IdProducto = Convert.ToInt32(drDetalle["IdProducto"]),
                                        Codigo = drDetalle["Codigo"].ToString(),
                                        Nombre = drDetalle["Nombre"].ToString()
                                    },
                                    Cantidad = Convert.ToInt32(drDetalle["Cantidad"]),
                                    PrecioUnitario = Convert.ToDecimal(drDetalle["PrecioUnitario"], new CultureInfo("es-PE")),
                                    TextoPrecioUnitario = Convert.ToDecimal(drDetalle["PrecioUnitario"], new CultureInfo("es-PE")).ToString("C", new CultureInfo("es-AR")),
                                    Subtotal = Convert.ToDecimal(drDetalle["Subtotal"], new CultureInfo("es-PE")),
                                    TextoSubtotal = Convert.ToDecimal(drDetalle["Subtotal"], new CultureInfo("es-PE")).ToString("C", new CultureInfo("es-AR"))
                                });
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    objeto = new Factura();
                }
            }
            return objeto;
        }
    }
}
