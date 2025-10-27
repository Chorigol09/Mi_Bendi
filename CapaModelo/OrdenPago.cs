using System;
using System.Collections.Generic;

namespace CapaModelo
{
    public class OrdenPago
    {
        public int IdOrdenPago { get; set; }
        public string NumeroOrdenPago { get; set; }
        public int IdFactura { get; set; }
        public string NumeroFactura { get; set; }
        public int IdProveedor { get; set; }
        public string NombreProveedor { get; set; }
        public string DocumentoProveedor { get; set; }
        public string CorreoProveedor { get; set; }
        public string TelefonoProveedor { get; set; }
        public string MetodoPago { get; set; }
        public decimal MontoTotal { get; set; }
        public DateTime FechaRegistro { get; set; }
        public DateTime? FechaFactura { get; set; }
        public string Estado { get; set; }
        public string UsuarioRegistro { get; set; }
        
        // Campos adicionales para mostrar
        public string FechaEmision { get; set; }
        public string Productos { get; set; }
        public int Cantidad { get; set; }
        
        // Lista de productos de la factura asociada
        public List<DetalleFactura> DetalleProductos { get; set; }

        public OrdenPago()
        {
            DetalleProductos = new List<DetalleFactura>();
        }
    }
}
