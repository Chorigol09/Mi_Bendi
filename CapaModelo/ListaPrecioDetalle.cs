using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class ListaPrecioDetalle
    {
        public int IdListaPrecioDetalle { get; set; }
        public int IdListaPrecio { get; set; }
        public ListaPrecio oListaPrecio { get; set; }
        public int IdProducto { get; set; }
        public Producto oProducto { get; set; }
        public decimal PrecioVenta { get; set; }
        public DateTime FechaVigenciaDesde { get; set; }
        public DateTime FechaVigenciaHasta { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaRegistro { get; set; }
        public bool EsVigente { get; set; }
        public string Categoria { get; set; }
    }
}
