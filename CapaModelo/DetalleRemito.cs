using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class DetalleRemito
    {
        public int IdDetalleRemito { get; set; }
        public int IdRemito { get; set; }
        public Producto oProducto { get; set; }
        public int Cantidad { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaRegistro { get; set; }
    }
}
