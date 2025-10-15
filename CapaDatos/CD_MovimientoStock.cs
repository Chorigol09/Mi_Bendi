using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaDatos
{
    public class CD_MovimientoStock
    {
        public static CD_MovimientoStock _instancia = null;

        private CD_MovimientoStock()
        {

        }

        public static CD_MovimientoStock Instancia
        {
            get
            {
                if (_instancia == null)
                {
                    _instancia = new CD_MovimientoStock();
                }
                return _instancia;
            }
        }

        public List<MovimientoStock> ObtenerMovimientos(int idTienda = 0)
        {
            List<MovimientoStock> lista = new List<MovimientoStock>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                SqlCommand cmd = new SqlCommand("usp_ObtenerMovimientosStock", oConexion);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("IdTienda", idTienda);

                try
                {
                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new MovimientoStock()
                        {
                            IdMovimiento = Convert.ToInt32(dr["IdMovimiento"].ToString()),
                            oTienda = new Tienda()
                            {
                                IdTienda = Convert.ToInt32(dr["IdTienda"].ToString()),
                                Nombre = dr["NombreTienda"].ToString()
                            },
                            oProducto = new Producto()
                            {
                                IdProducto = Convert.ToInt32(dr["IdProducto"].ToString()),
                                Codigo = dr["CodigoProducto"].ToString(),
                                Nombre = dr["NombreProducto"].ToString()
                            },
                            TipoMovimiento = dr["TipoMovimiento"].ToString(),
                            Cantidad = Convert.ToInt32(dr["Cantidad"].ToString()),
                            Motivo = dr["Motivo"].ToString(),
                            oUsuario = new Usuario()
                            {
                                IdUsuario = Convert.ToInt32(dr["IdUsuario"].ToString()),
                                Nombres = dr["NombreUsuario"].ToString()
                            },
                            IdLote = dr["IdLote"].ToString(),
                            FechaRegistro = Convert.ToDateTime(dr["FechaRegistro"].ToString())
                        });
                    }
                    dr.Close();

                    return lista;
                }
                catch (Exception ex)
                {
                    lista = null;
                    return lista;
                }
            }
        }

        public bool RegistrarMovimiento(MovimientoStock oMovimiento, out string mensaje)
        {
            bool respuesta = true;
            mensaje = string.Empty;
            
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_RegistrarMovimientoStock", oConexion);
                    cmd.Parameters.AddWithValue("IdTienda", oMovimiento.oTienda.IdTienda);
                    cmd.Parameters.AddWithValue("IdProducto", oMovimiento.oProducto.IdProducto);
                    cmd.Parameters.AddWithValue("TipoMovimiento", oMovimiento.TipoMovimiento);
                    cmd.Parameters.AddWithValue("Cantidad", oMovimiento.Cantidad);
                    cmd.Parameters.AddWithValue("Motivo", oMovimiento.Motivo);
                    cmd.Parameters.AddWithValue("IdUsuario", oMovimiento.oUsuario.IdUsuario);
                    cmd.Parameters.AddWithValue("IdLote", oMovimiento.IdLote ?? string.Empty);
                    cmd.Parameters.Add("Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("Mensaje", SqlDbType.VarChar, 500).Direction = ParameterDirection.Output;

                    cmd.CommandType = CommandType.StoredProcedure;

                    oConexion.Open();

                    cmd.ExecuteNonQuery();

                    respuesta = Convert.ToBoolean(cmd.Parameters["Resultado"].Value);
                    mensaje = cmd.Parameters["Mensaje"].Value.ToString();

                }
                catch (Exception ex)
                {
                    respuesta = false;
                    mensaje = "Error: " + ex.Message;
                }

            }

            return respuesta;
        }
    }
}
