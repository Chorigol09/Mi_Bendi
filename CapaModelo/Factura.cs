using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class Factura
    {
        public int IdFactura { get; set; }
        public int IdOrdenCompra { get; set; }
        public int IdProveedor { get; set; }
        public Compra oOrdenCompra { get; set; }
        public Proveedor oProveedor { get; set; }
        public Tienda oTienda { get; set; }
        public string NumeroFactura { get; set; }
        public decimal Total { get; set; }
        public string TextoTotal { get; set; }
        public string TextoFechaEmision { get; set; }
        public string Estado { get; set; } // "Pendiente", "Pagada" o "Cancelada"
        public string Observaciones { get; set; }
        public List<DetalleFactura> oListaDetalleFactura { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaEmision { get; set; }
        public DateTime? FechaPago { get; set; }
        // Campos adicionales para mostrar
        public string FechaOrdenCompra { get; set; }
        public int CantidadProductos { get; set; }
        public string Productos { get; set; }
    }
}
