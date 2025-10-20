using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class TipoMov
    {
        public int IdTipoMov { get; set; }
        public string Descripcion { get; set; }
        public string TipoOperacion { get; set; } // "Ingreso" o "Egreso"
        public bool Activo { get; set; }
        public DateTime FechaRegistro { get; set; }
    }
}
