using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class Remito
    {
        public int IdRemito { get; set; }
        public int IdOrdenCompra { get; set; }
        public Compra oOrdenCompra { get; set; }
        public Proveedor oProveedor { get; set; }
        public string NumeroRemito { get; set; }
        public string Estado { get; set; } // "En Espera" o "Recibido"
        public string Observaciones { get; set; }
        public List<DetalleRemito> oListaDetalleRemito { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaRegistro { get; set; }
        public DateTime? FechaRecepcion { get; set; }
        // Campos adicionales para mostrar
        public string FechaOrdenCompra { get; set; }
        public int CantidadProductos { get; set; }
        public string Productos { get; set; }
    }
}
