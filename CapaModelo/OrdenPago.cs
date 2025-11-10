using System;
using System.Collections.Generic;

namespace CapaModelo
{
    public class OrdenPago
    {
        public int IdOrdenPago { get; set; }
        public string NumeroOrdenPago { get; set; }
        public int IdFactura { get; set; } // Deprecated - mantener por compatibilidad
        public string NumeroFactura { get; set; }
        public int IdProveedor { get; set; }
        public string NombreProveedor { get; set; }
        public string DocumentoProveedor { get; set; }
        public string CorreoProveedor { get; set; }
        public string TelefonoProveedor { get; set; }
        public string MetodoPago { get; set; }
        public decimal MontoTotal { get; set; }
        public string Referencia { get; set; }
        public string NumeroTransaccion { get; set; }
        public DateTime FechaRegistro { get; set; }
        public DateTime? FechaFactura { get; set; }
        public string Estado { get; set; }
        public string UsuarioRegistro { get; set; }
        
        // Campos adicionales para mostrar
        public string FechaEmision { get; set; }
        public int CantidadFacturas { get; set; }
        
        // Lista de IDs de facturas para registrar orden de pago
        public List<int> IdsFacturas { get; set; }
        
        // Lista de productos de las facturas asociadas
        public List<DetalleFactura> DetalleProductos { get; set; }
        
        // Lista de facturas asociadas a la orden
        public List<FacturaOrdenPago> Facturas { get; set; }

        public OrdenPago()
        {
            IdsFacturas = new List<int>();
            DetalleProductos = new List<DetalleFactura>();
            Facturas = new List<FacturaOrdenPago>();
        }
    }
    
    // Clase para representar facturas en una orden de pago
    public class FacturaOrdenPago
    {
        public int IdDetalleOrdenPago { get; set; }
        public int IdFactura { get; set; }
        public string NumeroFactura { get; set; }
        public string FechaEmision { get; set; }
        public decimal MontoFactura { get; set; }
        public string Estado { get; set; }
    }
}
