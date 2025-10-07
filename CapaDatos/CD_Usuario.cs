using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Xml;
using System.Xml.Linq;

namespace CapaDatos
{
    public class CD_Usuario
    {
        public static CD_Usuario _instancia = null;

        private CD_Usuario() { }

        public static CD_Usuario Instancia
        {
            get
            {
                if (_instancia == null)
                {
                    _instancia = new CD_Usuario();
                }
                return _instancia;
            }
        }

        #region AUTENTICACIÓN (recomendado desde el Controller)

        /// <summary>
        /// Autentica por correo y clave (hash o como lo espere tu SP).
        /// Usa usp_LoginUsuario (devuelve IdUsuario por parámetro de salida)
        /// y luego carga el detalle con usp_ObtenerDetalleUsuario.
        /// </summary>
        public Usuario Autenticar(string correo, string clave)
        {
            int id = LoginUsuario(correo, clave);
            if (id <= 0) return null;
            return ObtenerDetalleUsuario(id);
        }

        /// <summary>
        /// Ejecuta usp_LoginUsuario y retorna el IdUsuario (0 si no existe).
        /// </summary>
        public int LoginUsuario(string usuarioCorreo, string clave)
        {
            int respuesta = 0;

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            using (SqlCommand cmd = new SqlCommand("usp_LoginUsuario", oConexion))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("Correo", usuarioCorreo ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("Clave", clave ?? (object)DBNull.Value);
                cmd.Parameters.Add("IdUsuario", SqlDbType.Int).Direction = ParameterDirection.Output;

                try
                {
                    oConexion.Open();
                    cmd.ExecuteNonQuery();
                    respuesta = Convert.ToInt32(cmd.Parameters["IdUsuario"].Value);
                }
                catch
                {
                    // opcional: log
                    respuesta = 0;
                }
            }

            return respuesta;
        }

        /// <summary>
        /// Carga un Usuario completo (Tienda, Rol, Menú) usando usp_ObtenerDetalleUsuario.
        /// </summary>
        public Usuario ObtenerDetalleUsuario(int idUsuario)
        {
            Usuario rptUsuario = null;

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            using (SqlCommand cmd = new SqlCommand("usp_ObtenerDetalleUsuario", oConexion))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);

                try
                {
                    oConexion.Open();
                    using (XmlReader dr = cmd.ExecuteXmlReader())
                    {
                        while (dr.Read())
                        {
                            XDocument doc = XDocument.Load(dr);

                            if (doc.Element("Usuario") == null)
                            {
                                rptUsuario = null;
                                continue;
                            }

                            rptUsuario = (from dato in doc.Elements("Usuario")
                                          select new Usuario()
                                          {
                                              IdUsuario = int.Parse(dato.Element("IdUsuario").Value),
                                              Nombres = dato.Element("Nombres").Value,
                                              Apellidos = dato.Element("Apellidos").Value,
                                              Correo = dato.Element("Correo").Value,
                                              Clave = dato.Element("Clave").Value
                                          }).FirstOrDefault();

                            if (rptUsuario == null) continue;

                            rptUsuario.oTienda = (from dato in doc.Element("Usuario").Elements("DetalleTienda")
                                                  select new Tienda()
                                                  {
                                                      IdTienda = int.Parse(dato.Element("IdTienda").Value),
                                                      Nombre = dato.Element("Nombre").Value,
                                                      RUC = dato.Element("RUC").Value,
                                                      Direccion = dato.Element("Direccion").Value,
                                                      Telefono = dato.Element("Telefono").Value
                                                  }).FirstOrDefault();

                            rptUsuario.oRol = (from dato in doc.Element("Usuario").Elements("DetalleRol")
                                               select new Rol()
                                               {
                                                   Descripcion = dato.Element("Descripcion").Value
                                               }).FirstOrDefault();

                            rptUsuario.oListaMenu = (from menu in doc.Element("Usuario").Element("DetalleMenu").Elements("Menu")
                                                     select new Menu()
                                                     {
                                                         Nombre = menu.Element("NombreMenu").Value,
                                                         Icono = menu.Element("Icono").Value,
                                                         oSubMenu = (from submenu in menu.Element("DetalleSubMenu").Elements("SubMenu")
                                                                     select new SubMenu()
                                                                     {
                                                                         Nombre = submenu.Element("NombreSubMenu").Value,
                                                                         Controlador = submenu.Element("Controlador").Value,
                                                                         Vista = submenu.Element("Vista").Value,
                                                                         Icono = submenu.Element("Icono").Value,
                                                                         Activo = (submenu.Element("Activo").Value == "1")
                                                                     }).ToList()
                                                     }).ToList();
                        }
                    }
                }
                catch
                {
                    rptUsuario = null;
                }
            }

            return rptUsuario;
        }

        #endregion

        #region CRUD BÁSICO (compatibilidad con tu código actual)

        /// <summary>
        /// NUNCA retorna null. Devuelve lista vacía si no hay datos o ante error.
        /// </summary>
        public List<Usuario> ObtenerUsuarios()
        {
            var rptListaUsuario = new List<Usuario>();

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            using (SqlCommand cmd = new SqlCommand("usp_ObtenerUsuario", oConexion))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                try
                {
                    oConexion.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            var u = new Usuario
                            {
                                IdUsuario = Convert.ToInt32(dr["IdUsuario"]),
                                Nombres = dr["Nombres"].ToString(),
                                Apellidos = dr["Apellidos"].ToString(),
                                Correo = dr["Correo"].ToString(),
                                Clave = dr["Clave"].ToString(),
                                IdTienda = Convert.ToInt32(dr["IdTienda"]),
                                IdRol = Convert.ToInt32(dr["IdRol"]),
                                oRol = new Rol { Descripcion = dr["DescripcionRol"].ToString() },
                                Activo = Convert.ToBoolean(dr["Activo"])
                            };

                            rptListaUsuario.Add(u);
                        }
                    }
                }
                catch
                {
                    // opcional: log
                    // Importante: NO reasignamos a null. Mantenemos lista vacía.
                }
            }

            return rptListaUsuario; // nunca null
        }

        public bool RegistrarUsuario(Usuario oUsuario)
        {
            bool respuesta = false;

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            using (SqlCommand cmd = new SqlCommand("usp_RegistrarUsuario", oConexion))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("Nombres", oUsuario.Nombres ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("Apellidos", oUsuario.Apellidos ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("Correo", oUsuario.Correo ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("Clave", oUsuario.Clave ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("IdTienda", oUsuario.IdTienda);
                cmd.Parameters.AddWithValue("IdRol", oUsuario.IdRol);
                cmd.Parameters.Add("Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;

                try
                {
                    oConexion.Open();
                    cmd.ExecuteNonQuery();
                    respuesta = Convert.ToBoolean(cmd.Parameters["Resultado"].Value);
                }
                catch
                {
                    respuesta = false;
                }
            }

            return respuesta;
        }

        public bool ModificarUsuario(Usuario oUsuario)
        {
            bool respuesta = false;

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            using (SqlCommand cmd = new SqlCommand("usp_ModificarUsuario", oConexion))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("IdUsuario", oUsuario.IdUsuario);
                cmd.Parameters.AddWithValue("Nombres", oUsuario.Nombres ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("Apellidos", oUsuario.Apellidos ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("Correo", oUsuario.Correo ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("Clave", oUsuario.Clave ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("IdTienda", oUsuario.IdTienda);
                cmd.Parameters.AddWithValue("IdRol", oUsuario.IdRol);
                cmd.Parameters.AddWithValue("Activo", oUsuario.Activo);
                cmd.Parameters.Add("Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;

                try
                {
                    oConexion.Open();
                    cmd.ExecuteNonQuery();
                    respuesta = Convert.ToBoolean(cmd.Parameters["Resultado"].Value);
                }
                catch
                {
                    respuesta = false;
                }
            }

            return respuesta;
        }

        public bool EliminarUsuario(int idUsuario)
        {
            bool respuesta = false;

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            using (SqlCommand cmd = new SqlCommand("usp_EliminarUsuario", oConexion))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("IdUsuario", idUsuario);
                cmd.Parameters.Add("Resultado", SqlDbType.Bit).Direction = ParameterDirection.Output;

                try
                {
                    oConexion.Open();
                    cmd.ExecuteNonQuery();
                    respuesta = Convert.ToBoolean(cmd.Parameters["Resultado"].Value);
                }
                catch
                {
                    respuesta = false;
                }
            }

            return respuesta;
        }

        #endregion
    }
}
