using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;

namespace CapaDatos
{
    public class CD_Remito
    {
        public static CD_Remito _instancia = null;

        private CD_Remito()
        {
        }

        public static CD_Remito Instancia
        {
            get
            {
                if (_instancia == null)
                {
                    _instancia = new CD_Remito();
                }
                return _instancia;
            }
        }

        public List<Remito> ObtenerRemitos()
        {
            List<Remito> lista = new List<Remito>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_ObtenerRemitos", oConexion);
                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new Remito()
                        {
                            IdRemito = Convert.ToInt32(dr["IdRemito"]),
                            IdOrdenCompra = Convert.ToInt32(dr["IdOrdenCompra"]),
                            oProveedor = new Proveedor()
                            {
                                IdProveedor = Convert.ToInt32(dr["IdProveedor"]),
                                RazonSocial = dr["RazonSocial"].ToString()
                            },
                            NumeroRemito = dr["NumeroRemito"].ToString(),
                            Estado = dr["Estado"].ToString(),
                            Observaciones = dr["Observaciones"].ToString(),
                            Activo = Convert.ToBoolean(dr["Activo"]),
                            FechaRegistro = Convert.ToDateTime(dr["FechaRegistro"]),
                            FechaRecepcion = dr["FechaRecepcion"] != DBNull.Value ? Convert.ToDateTime(dr["FechaRecepcion"]) : (DateTime?)null,
                            FechaOrdenCompra = dr["FechaOrdenCompra"] != DBNull.Value ? dr["FechaOrdenCompra"].ToString() : "",
                            CantidadProductos = dr["CantidadProductos"] != DBNull.Value ? Convert.ToInt32(dr["CantidadProductos"]) : 0,
                            Productos = dr["Productos"] != DBNull.Value ? dr["Productos"].ToString() : ""
                        });
                    }
                    dr.Close();
                }
                catch (Exception ex)
                {
                    lista = new List<Remito>();
                }
            }
            return lista;
        }

        public bool RegistrarRemito(Remito remito)
        {
            bool respuesta = false;
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_RegistrarRemito", oConexion);
                    cmd.Parameters.AddWithValue("@IdOrdenCompra", remito.IdOrdenCompra);
                    cmd.Parameters.AddWithValue("@IdProveedor", remito.oProveedor.IdProveedor);
                    cmd.Parameters.AddWithValue("@NumeroRemito", remito.NumeroRemito);
                    cmd.Parameters.AddWithValue("@Observaciones", remito.Observaciones ?? "");
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

        public bool ActualizarEstadoRemito(int idRemito, string estado, int idUsuario)
        {
            bool respuesta = false;
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_ActualizarEstadoRemito", oConexion);
                    cmd.Parameters.AddWithValue("@IdRemito", idRemito);
                    cmd.Parameters.AddWithValue("@Estado", estado);
                    cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);
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
