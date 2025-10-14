using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;

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
                            IdOrdenCompra = Convert.ToInt32(dr["IdOrdenCompra"]),
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
    }
}
