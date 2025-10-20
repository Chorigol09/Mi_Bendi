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
    public class CD_TipoMov
    {
        public static CD_TipoMov _instancia = null;

        private CD_TipoMov()
        {

        }

        public static CD_TipoMov Instancia
        {
            get
            {
                if (_instancia == null)
                {
                    _instancia = new CD_TipoMov();
                }
                return _instancia;
            }
        }

        public List<TipoMov> ObtenerTiposMov()
        {
            List<TipoMov> lista = new List<TipoMov>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                SqlCommand cmd = new SqlCommand("usp_ObtenerTiposMov", oConexion);
                cmd.CommandType = CommandType.StoredProcedure;

                try
                {
                    oConexion.Open();
                    SqlDataReader dr = cmd.ExecuteReader();

                    while (dr.Read())
                    {
                        lista.Add(new TipoMov()
                        {
                            IdTipoMov = Convert.ToInt32(dr["IdTipoMov"].ToString()),
                            Descripcion = dr["Descripcion"].ToString(),
                            TipoOperacion = dr["TipoOperacion"].ToString(),
                            Activo = Convert.ToBoolean(dr["Activo"]),
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
    }
}
