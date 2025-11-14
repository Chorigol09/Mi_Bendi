using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CapaModelo
{
    public class ResumenGeneral
    {
        public decimal TotalVentas { get; set; }
        public int CantidadVentas { get; set; }
        public decimal PromedioVenta { get; set; }
        public int UnidadesVendidas { get; set; }
        public decimal TotalCompras { get; set; }
        public int CantidadCompras { get; set; }
        public decimal MargenBruto { get; set; }
        public int ClientesUnicos { get; set; }
    }

    public class VentaPorTienda
    {
        public string Tienda { get; set; }
        public int CantidadVentas { get; set; }
        public decimal TotalVendido { get; set; }
        public decimal PromedioVenta { get; set; }
    }

    public class VentaPorTipoDocumento
    {
        public string TipoDocumento { get; set; }
        public int Cantidad { get; set; }
        public decimal Total { get; set; }
    }

    public class VentaPorMetodoPago
    {
        public string MetodoPago { get; set; }
        public int Cantidad { get; set; }
        public decimal Total { get; set; }
    }

    public class TopCliente
    {
        public string Cliente { get; set; }
        public string NumeroDocumento { get; set; }
        public int CantidadCompras { get; set; }
        public decimal TotalComprado { get; set; }
    }

    public class TopProducto
    {
        public string Producto { get; set; }
        public string Codigo { get; set; }
        public int CantidadVendida { get; set; }
        public decimal TotalVendido { get; set; }
    }

    public class VentaPorDia
    {
        public DateTime Fecha { get; set; }
        public int CantidadVentas { get; set; }
        public decimal TotalVendido { get; set; }
    }

    public class CompraPorProveedor
    {
        public string Proveedor { get; set; }
        public int CantidadCompras { get; set; }
        public decimal TotalComprado { get; set; }
    }

    public class CompraPorDia
    {
        public DateTime Fecha { get; set; }
        public int CantidadCompras { get; set; }
        public decimal TotalComprado { get; set; }
    }

    public class TopProductoComprado
    {
        public string Producto { get; set; }
        public string Codigo { get; set; }
        public int CantidadComprada { get; set; }
        public decimal TotalComprado { get; set; }
    }

    public class TopProveedor
    {
        public string Proveedor { get; set; }
        public string NumeroDocumento { get; set; }
        public int CantidadCompras { get; set; }
        public decimal TotalComprado { get; set; }
    }
}
