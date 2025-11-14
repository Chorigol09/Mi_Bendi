using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;

namespace CapaDatos
{
    public class CD_Indicadores
    {
        public static CD_Indicadores _instancia = null;

        private CD_Indicadores()
        {
        }

        public static CD_Indicadores Instancia
        {
            get
            {
                if (_instancia == null)
                {
                    _instancia = new CD_Indicadores();
                }
                return _instancia;
            }
        }

        public ResumenGeneral ObtenerResumenGeneral(DateTime fechaInicio, DateTime fechaFin)
        {
            ResumenGeneral resumen = new ResumenGeneral();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_IndicadorResumenGeneral", oConexion);
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    if (dr.Read())
                    {
                        resumen.TotalVentas = dr["TotalVentas"] != DBNull.Value ? Convert.ToDecimal(dr["TotalVentas"]) : 0;
                        resumen.CantidadVentas = dr["CantidadVentas"] != DBNull.Value ? Convert.ToInt32(dr["CantidadVentas"]) : 0;
                        resumen.PromedioVenta = dr["PromedioVenta"] != DBNull.Value ? Convert.ToDecimal(dr["PromedioVenta"]) : 0;
                        resumen.UnidadesVendidas = dr["UnidadesVendidas"] != DBNull.Value ? Convert.ToInt32(dr["UnidadesVendidas"]) : 0;
                        resumen.TotalCompras = dr["TotalCompras"] != DBNull.Value ? Convert.ToDecimal(dr["TotalCompras"]) : 0;
                        resumen.CantidadCompras = dr["CantidadCompras"] != DBNull.Value ? Convert.ToInt32(dr["CantidadCompras"]) : 0;
                        resumen.MargenBruto = dr["MargenBruto"] != DBNull.Value ? Convert.ToDecimal(dr["MargenBruto"]) : 0;
                        resumen.ClientesUnicos = dr["ClientesUnicos"] != DBNull.Value ? Convert.ToInt32(dr["ClientesUnicos"]) : 0;
                    }
                    dr.Close();
                }
                catch (Exception)
                {
                    resumen = new ResumenGeneral();
                }
            }
            return resumen;
        }

        public List<VentaPorTienda> ObtenerVentasPorTienda(DateTime fechaInicio, DateTime fechaFin)
        {
            List<VentaPorTienda> lista = new List<VentaPorTienda>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_IndicadorVentasPorTienda", oConexion);
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new VentaPorTienda()
                        {
                            Tienda = dr["Tienda"].ToString(),
                            CantidadVentas = Convert.ToInt32(dr["CantidadVentas"]),
                            TotalVendido = Convert.ToDecimal(dr["TotalVendido"]),
                            PromedioVenta = Convert.ToDecimal(dr["PromedioVenta"])
                        });
                    }
                    dr.Close();
                }
                catch (Exception)
                {
                    lista = new List<VentaPorTienda>();
                }
            }
            return lista;
        }

        public List<VentaPorTipoDocumento> ObtenerVentasPorTipoDocumento(DateTime fechaInicio, DateTime fechaFin)
        {
            List<VentaPorTipoDocumento> lista = new List<VentaPorTipoDocumento>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_IndicadorVentasPorTipoDocumento", oConexion);
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new VentaPorTipoDocumento()
                        {
                            TipoDocumento = dr["TipoDocumento"].ToString(),
                            Cantidad = Convert.ToInt32(dr["Cantidad"]),
                            Total = Convert.ToDecimal(dr["Total"])
                        });
                    }
                    dr.Close();
                }
                catch (Exception)
                {
                    lista = new List<VentaPorTipoDocumento>();
                }
            }
            return lista;
        }

        public List<VentaPorMetodoPago> ObtenerVentasPorMetodoPago(DateTime fechaInicio, DateTime fechaFin)
        {
            List<VentaPorMetodoPago> lista = new List<VentaPorMetodoPago>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_IndicadorVentasPorMetodoPago", oConexion);
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new VentaPorMetodoPago()
                        {
                            MetodoPago = dr["MetodoPago"].ToString(),
                            Cantidad = Convert.ToInt32(dr["Cantidad"]),
                            Total = Convert.ToDecimal(dr["Total"])
                        });
                    }
                    dr.Close();
                }
                catch (Exception)
                {
                    lista = new List<VentaPorMetodoPago>();
                }
            }
            return lista;
        }

        public List<TopCliente> ObtenerTopClientes(DateTime fechaInicio, DateTime fechaFin, int top = 10)
        {
            List<TopCliente> lista = new List<TopCliente>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_IndicadorTopClientes", oConexion);
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin);
                    cmd.Parameters.AddWithValue("@Top", top);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new TopCliente()
                        {
                            Cliente = dr["Cliente"].ToString(),
                            NumeroDocumento = dr["NumeroDocumento"].ToString(),
                            CantidadCompras = Convert.ToInt32(dr["CantidadCompras"]),
                            TotalComprado = Convert.ToDecimal(dr["TotalComprado"])
                        });
                    }
                    dr.Close();
                }
                catch (Exception)
                {
                    lista = new List<TopCliente>();
                }
            }
            return lista;
        }

        public List<TopProducto> ObtenerTopProductos(DateTime fechaInicio, DateTime fechaFin, int top = 10)
        {
            List<TopProducto> lista = new List<TopProducto>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_IndicadorTopProductos", oConexion);
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin);
                    cmd.Parameters.AddWithValue("@Top", top);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new TopProducto()
                        {
                            Producto = dr["Producto"].ToString(),
                            Codigo = dr["Codigo"].ToString(),
                            CantidadVendida = Convert.ToInt32(dr["CantidadVendida"]),
                            TotalVendido = Convert.ToDecimal(dr["TotalVendido"])
                        });
                    }
                    dr.Close();
                }
                catch (Exception)
                {
                    lista = new List<TopProducto>();
                }
            }
            return lista;
        }

        public List<VentaPorDia> ObtenerVentasPorDia(DateTime fechaInicio, DateTime fechaFin)
        {
            List<VentaPorDia> lista = new List<VentaPorDia>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_IndicadorVentasPorDia", oConexion);
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new VentaPorDia()
                        {
                            Fecha = Convert.ToDateTime(dr["Fecha"]),
                            CantidadVentas = Convert.ToInt32(dr["CantidadVentas"]),
                            TotalVendido = Convert.ToDecimal(dr["TotalVendido"])
                        });
                    }
                    dr.Close();
                }
                catch (Exception)
                {
                    lista = new List<VentaPorDia>();
                }
            }
            return lista;
        }

        public List<CompraPorProveedor> ObtenerComprasPorProveedor(DateTime fechaInicio, DateTime fechaFin)
        {
            List<CompraPorProveedor> lista = new List<CompraPorProveedor>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_IndicadorComprasPorProveedor", oConexion);
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new CompraPorProveedor()
                        {
                            Proveedor = dr["Proveedor"].ToString(),
                            CantidadCompras = Convert.ToInt32(dr["CantidadCompras"]),
                            TotalComprado = Convert.ToDecimal(dr["TotalComprado"])
                        });
                    }
                    dr.Close();
                }
                catch (Exception)
                {
                    lista = new List<CompraPorProveedor>();
                }
            }
            return lista;
        }

        public List<CompraPorDia> ObtenerComprasPorDia(DateTime fechaInicio, DateTime fechaFin)
        {
            List<CompraPorDia> lista = new List<CompraPorDia>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_IndicadorComprasPorDia", oConexion);
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new CompraPorDia()
                        {
                            Fecha = Convert.ToDateTime(dr["Fecha"]),
                            CantidadCompras = Convert.ToInt32(dr["CantidadCompras"]),
                            TotalComprado = Convert.ToDecimal(dr["TotalComprado"])
                        });
                    }
                    dr.Close();
                }
                catch (Exception)
                {
                    lista = new List<CompraPorDia>();
                }
            }
            return lista;
        }

        public List<TopProductoComprado> ObtenerTopProductosComprados(DateTime fechaInicio, DateTime fechaFin, int top = 10)
        {
            List<TopProductoComprado> lista = new List<TopProductoComprado>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_IndicadorTopProductosComprados", oConexion);
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin);
                    cmd.Parameters.AddWithValue("@Top", top);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new TopProductoComprado()
                        {
                            Producto = dr["Producto"].ToString(),
                            Codigo = dr["Codigo"].ToString(),
                            CantidadComprada = Convert.ToInt32(dr["CantidadComprada"]),
                            TotalComprado = Convert.ToDecimal(dr["TotalComprado"])
                        });
                    }
                    dr.Close();
                }
                catch (Exception)
                {
                    lista = new List<TopProductoComprado>();
                }
            }
            return lista;
        }

        public List<TopProveedor> ObtenerTopProveedores(DateTime fechaInicio, DateTime fechaFin, int top = 10)
        {
            List<TopProveedor> lista = new List<TopProveedor>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_IndicadorTopProveedores", oConexion);
                    cmd.Parameters.AddWithValue("@FechaInicio", fechaInicio);
                    cmd.Parameters.AddWithValue("@FechaFin", fechaFin);
                    cmd.Parameters.AddWithValue("@Top", top);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new TopProveedor()
                        {
                            Proveedor = dr["Proveedor"].ToString(),
                            NumeroDocumento = dr["NumeroDocumento"].ToString(),
                            CantidadCompras = Convert.ToInt32(dr["CantidadCompras"]),
                            TotalComprado = Convert.ToDecimal(dr["TotalComprado"])
                        });
                    }
                    dr.Close();
                }
                catch (Exception)
                {
                    lista = new List<TopProveedor>();
                }
            }
            return lista;
        }
    }
}
