using CapaModelo;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;

namespace CapaDatos
{
    public class CD_OrdenPago
    {
        public static CD_OrdenPago _instancia = null;

        private CD_OrdenPago()
        {
        }

        public static CD_OrdenPago Instancia
        {
            get
            {
                if (_instancia == null)
                {
                    _instancia = new CD_OrdenPago();
                }
                return _instancia;
            }
        }

        // Obtener facturas pendientes por proveedor
        public List<Factura> ObtenerFacturasPendientes(int idProveedor)
        {
            List<Factura> lista = new List<Factura>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("SP_OBTENER_FACTURAS_PENDIENTES", oConexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdProveedor", idProveedor);

                    oConexion.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            // Parsear fecha desde string dd/mm/yyyy
                            string fechaStr = dr["FechaEmision"].ToString();
                            DateTime fechaEmision = DateTime.ParseExact(fechaStr, "dd/MM/yyyy", System.Globalization.CultureInfo.InvariantCulture);
                            
                            lista.Add(new Factura
                            {
                                IdFactura = Convert.ToInt32(dr["IdFactura"]),
                                NumeroFactura = dr["NumeroFactura"].ToString(),
                                NombreProveedor = dr["NombreProveedor"].ToString(),
                                FechaEmision = fechaEmision,
                                TextoFechaEmision = fechaStr, // Guardar tambien como string
                                MontoTotal = Convert.ToDecimal(dr["MontoTotal"])
                            });
                        }
                    }
                }
                catch (Exception)
                {
                    lista = new List<Factura>();
                }
            }
            return lista;
        }

        // Registrar nueva orden de pago con múltiples facturas
        public bool RegistrarOrdenPago(OrdenPago obj, out string Mensaje, out int IdOrdenPago)
        {
            bool respuesta = false;
            Mensaje = string.Empty;
            IdOrdenPago = 0;

            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("SP_REGISTRAR_ORDEN_PAGO", oConexion);
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Convertir lista de IDs a string separado por comas
                    string idsFacturas = string.Join(",", obj.IdsFacturas);
                    
                    cmd.Parameters.AddWithValue("@IdsFacturas", idsFacturas);
                    cmd.Parameters.AddWithValue("@IdProveedor", obj.IdProveedor);
                    cmd.Parameters.AddWithValue("@MetodoPago", obj.MetodoPago);
                    cmd.Parameters.AddWithValue("@MontoTotal", obj.MontoTotal);
                    cmd.Parameters.AddWithValue("@UsuarioRegistro", obj.UsuarioRegistro);
                    cmd.Parameters.AddWithValue("@Referencia", string.IsNullOrEmpty(obj.Referencia) ? (object)DBNull.Value : obj.Referencia);
                    cmd.Parameters.AddWithValue("@NumeroTransaccion", string.IsNullOrEmpty(obj.NumeroTransaccion) ? (object)DBNull.Value : obj.NumeroTransaccion);

                    SqlParameter paramResultado = new SqlParameter("@Resultado", SqlDbType.Bit) { Direction = ParameterDirection.Output };
                    SqlParameter paramMensaje = new SqlParameter("@Mensaje", SqlDbType.VarChar, 500) { Direction = ParameterDirection.Output };
                    SqlParameter paramIdOrdenPago = new SqlParameter("@IdOrdenPago", SqlDbType.Int) { Direction = ParameterDirection.Output };

                    cmd.Parameters.Add(paramResultado);
                    cmd.Parameters.Add(paramMensaje);
                    cmd.Parameters.Add(paramIdOrdenPago);

                    oConexion.Open();
                    cmd.ExecuteNonQuery();

                    respuesta = Convert.ToBoolean(paramResultado.Value);
                    Mensaje = paramMensaje.Value.ToString();
                    IdOrdenPago = paramIdOrdenPago.Value != DBNull.Value ? Convert.ToInt32(paramIdOrdenPago.Value) : 0;
                }
                catch (Exception ex)
                {
                    respuesta = false;
                    Mensaje = ex.Message;
                }
            }
            return respuesta;
        }

        // Obtener todas las órdenes de pago
        public List<OrdenPago> ObtenerOrdenesPago(int? idProveedor = null)
        {
            List<OrdenPago> lista = new List<OrdenPago>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("SP_OBTENER_ORDENES_PAGO", oConexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdProveedor", idProveedor.HasValue ? (object)idProveedor.Value : DBNull.Value);

                    oConexion.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new OrdenPago
                            {
                                IdOrdenPago = Convert.ToInt32(dr["IdOrdenPago"]),
                                NumeroOrdenPago = dr["NumeroOrdenPago"].ToString(),
                                IdFactura = dr["IdFactura"] != DBNull.Value ? Convert.ToInt32(dr["IdFactura"]) : 0,
                                NumeroFactura = dr["NumeroFactura"].ToString(),
                                IdProveedor = Convert.ToInt32(dr["IdProveedor"]),
                                NombreProveedor = dr["NombreProveedor"].ToString(),
                                FechaEmision = dr["FechaEmision"].ToString(),
                                CantidadFacturas = dr["CantidadFacturas"] != DBNull.Value ? Convert.ToInt32(dr["CantidadFacturas"]) : 0,
                                MetodoPago = dr["MetodoPago"].ToString(),
                                MontoTotal = Convert.ToDecimal(dr["MontoTotal"]),
                                FechaRegistro = Convert.ToDateTime(dr["FechaRegistro"]),
                                Estado = dr["Estado"].ToString(),
                                UsuarioRegistro = dr["UsuarioRegistro"].ToString()
                            });
                        }
                    }
                }
                catch (Exception)
                {
                    lista = new List<OrdenPago>();
                }
            }
            return lista;
        }

        // Obtener detalle de orden de pago
        public OrdenPago ObtenerDetalleOrdenPago(int idOrdenPago)
        {
            OrdenPago obj = new OrdenPago();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("SP_OBTENER_DETALLE_ORDEN_PAGO", oConexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdOrdenPago", idOrdenPago);

                    oConexion.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        // Primer ResultSet: Datos de la orden
                        if (dr.Read())
                        {
                            obj.IdOrdenPago = Convert.ToInt32(dr["IdOrdenPago"]);
                            obj.NumeroOrdenPago = dr["NumeroOrdenPago"].ToString();
                            obj.IdFactura = Convert.ToInt32(dr["IdFactura"]);
                            obj.NumeroFactura = dr["NumeroFactura"].ToString();
                            obj.IdProveedor = Convert.ToInt32(dr["IdProveedor"]);
                            obj.NombreProveedor = dr["NombreProveedor"].ToString();
                            obj.DocumentoProveedor = dr["DocumentoProveedor"].ToString();
                            obj.CorreoProveedor = dr["CorreoProveedor"].ToString();
                            obj.TelefonoProveedor = dr["TelefonoProveedor"].ToString();
                            obj.MetodoPago = dr["MetodoPago"].ToString();
                            obj.MontoTotal = Convert.ToDecimal(dr["MontoTotal"]);
                            obj.Referencia = dr["Referencia"] != DBNull.Value ? dr["Referencia"].ToString() : null;
                            obj.NumeroTransaccion = dr["NumeroTransaccion"] != DBNull.Value ? dr["NumeroTransaccion"].ToString() : null;
                            obj.FechaRegistro = Convert.ToDateTime(dr["FechaRegistro"]);
                            obj.FechaFactura = Convert.ToDateTime(dr["FechaFactura"]);
                            obj.Estado = dr["Estado"].ToString();
                            obj.UsuarioRegistro = dr["UsuarioRegistro"].ToString();
                        }

                        // Segundo ResultSet: Detalle de productos
                        if (dr.NextResult())
                        {
                            while (dr.Read())
                            {
                                obj.DetalleProductos.Add(new DetalleFactura
                                {
                                    IdDetalleFactura = Convert.ToInt32(dr["IdDetalleFactura"]),
                                    IdProducto = Convert.ToInt32(dr["IdProducto"]),
                                    NombreProducto = dr["NombreProducto"].ToString(),
                                    CodigoProducto = dr["CodigoProducto"].ToString(),
                                    Cantidad = Convert.ToInt32(dr["Cantidad"]),
                                    PrecioUnitario = Convert.ToDecimal(dr["PrecioUnitario"]),
                                    Subtotal = Convert.ToDecimal(dr["Subtotal"])
                                });
                            }
                        }
                    }
                }
                catch (Exception)
                {
                    obj = new OrdenPago();
                }
            }
            return obj;
        }

        // Obtener facturas asociadas a una orden de pago
        public List<FacturaOrdenPago> ObtenerFacturasOrdenPago(int idOrdenPago)
        {
            List<FacturaOrdenPago> lista = new List<FacturaOrdenPago>();
            using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("SP_OBTENER_FACTURAS_ORDEN_PAGO", oConexion);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@IdOrdenPago", idOrdenPago);

                    oConexion.Open();

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            lista.Add(new FacturaOrdenPago
                            {
                                IdDetalleOrdenPago = Convert.ToInt32(dr["IdDetalleOrdenPago"]),
                                IdFactura = Convert.ToInt32(dr["IdFactura"]),
                                NumeroFactura = dr["NumeroFactura"].ToString(),
                                FechaEmision = dr["FechaEmision"].ToString(),
                                MontoFactura = Convert.ToDecimal(dr["MontoFactura"]),
                                Estado = dr["Estado"].ToString()
                            });
                        }
                    }
                }
                catch (Exception)
                {
                    lista = new List<FacturaOrdenPago>();
                }
            }
            return lista;
        }
    }
}
