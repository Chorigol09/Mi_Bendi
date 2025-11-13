using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class ListaPrecio
    {
        public int IdListaPrecio { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }
        public string TipoLista { get; set; }
        public int? IdTienda { get; set; }
        public Tienda oTienda { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaRegistro { get; set; }
        public int CantidadProductos { get; set; }
        public int ProductosVigentes { get; set; }
    }
}
