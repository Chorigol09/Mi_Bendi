using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class MovimientoStock
    {
        public int IdMovimiento { get; set; }
        public Tienda oTienda { get; set; }
        public Producto oProducto { get; set; }
        public string TipoMovimiento { get; set; } // "Ingreso" o "Egreso"
        public int Cantidad { get; set; }
        public string Motivo { get; set; }
        public Usuario oUsuario { get; set; }
        public string IdLote { get; set; } // Para agrupar movimientos registrados juntos
        public DateTime FechaRegistro { get; set; }
    }
}
