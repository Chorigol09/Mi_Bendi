var tabladata;

$(document).ready(function () {
    activarMenu("Compras");

    // Cargar proveedores
    jQuery.ajax({
        url: $.MisUrls.url._ObtenerProveedores,
        type: "GET",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.data != null) {
                $("#cboProveedor").append($("<option>").val("0").text("Todos"));
                $.each(data.data, function (i, item) {
                    if (item.Activo == true) {
                        $("#cboProveedor").append($("<option>").val(item.IdProveedor).text(item.RazonSocial));
                    }
                })
            }
        },
        error: function (error) {
            console.log(error)
        }
    });

    // Inicializar DataTable
    tabladata = $('#tbFacturas').DataTable({
        "ajax": {
            "url": $.MisUrls.url._ObtenerFacturas,
            "type": "GET",
            "datatype": "json"
        },
        "columns": [
            { 
                "data": "NumeroFactura",
                "className": "text-center",
                "width": "100px"
            },
            { 
                "data": "RazonSocial",
                "render": function(data) {
                    if (data && data.length > 25) {
                        return '<span title="' + data + '">' + data.substring(0, 25) + '...</span>';
                    }
                    return data || '';
                },
                "width": "150px"
            },
            { 
                "data": "FechaEmision",
                "render": function(data) {
                    if (data) {
                        var fecha = new Date(data);
                        return fecha.toLocaleDateString('es-AR');
                    }
                    return '';
                },
                "className": "text-center",
                "width": "90px"
            },
            { 
                "data": "Total",
                "className": "text-right",
                "render": function(data) {
                    return formatearPrecio(data);
                },
                "width": "100px"
            },
            { 
                "data": "CantidadProductos",
                "className": "text-right",
                "width": "60px"
            },
            { 
                "data": "Productos",
                "render": function(data) {
                    if (!data || data == '') return '<em class="text-muted">-</em>';
                    if (data && data.length > 40) {
                        return '<span title="' + data + '">' + data.substring(0, 40) + '...</span>';
                    }
                    return data || '';
                },
                "width": "180px"
            },
            {
                "data": "Estado",
                render: function (data, type, row) {
                    var badgeClass = '';
                    var badgeSize = 'badge-pill px-2 py-1';
                    var texto = '';
                    
                    if (data == 'Pendiente') {
                        badgeClass = 'badge-warning';
                        texto = 'PENDIENTE';
                    } else if (data == 'Pagada' || data == 'Pagado') {
                        badgeClass = 'badge-success';
                        texto = 'PAGADO';
                    } else if (data == 'Cancelada') {
                        badgeClass = 'badge-danger';
                        texto = 'CANCELADO';
                    } else {
                        badgeClass = 'badge-secondary';
                        texto = data ? data.toUpperCase() : '';
                    }
                    
                    return '<span class="badge ' + badgeClass + ' ' + badgeSize + '" style="font-size: 0.85rem; display: block;">' + texto + '</span>';
                },
                "orderable": true,
                "width": "100px"
            }
        ],
        "language": {
            "url": $.MisUrls.url.Url_datatable_spanish
        },
        "order": [[2, "desc"]], // Ordenar por fecha descendente
        "autoWidth": false
    });

});

// Función para formatear precio
function formatearPrecio(valor) {
    if (!valor || isNaN(valor)) return '$0,00';
    var numero = parseFloat(valor);
    var partes = numero.toFixed(2).split('.');
    partes[0] = partes[0].replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    return '$' + partes[0] + ',' + partes[1];
}

function buscar() {
    var idProveedor = $("#cboProveedor").val();
    var estado = $("#cboEstado").val();
    var orden = $("#cboOrden").val();

    // Recargar tabla con filtros
    tabladata.ajax.reload();
}

function verDetalle(idFactura) {
    // Redirigir a una página de detalle
    window.location.href = '/Factura/Detalle?id=' + idFactura;
}
