
var tabladata;

$(document).ready(function () {
    activarMenu("Compras");

    $.datepicker.regional['es'] = {
        closeText: 'Cerrar',
        prevText: '< Ant',
        nextText: 'Sig >',
        currentText: 'Hoy',
        monthNames: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
        monthNamesShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
        dayNames: ['Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'],
        dayNamesShort: ['Dom', 'Lun', 'Mar', 'Mie', 'Juv', 'Vie', 'Sab'],
        dayNamesMin: ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa'],
        weekHeader: 'Sm',
        dateFormat: 'dd/mm/yy',
        firstDay: 1,
        isRTL: false,
        showMonthAfterYear: false,
        yearSuffix: ''
    };
    $.datepicker.setDefaults($.datepicker.regional['es']);


    $("#txtFechaInicio").datepicker();
    $("#txtFechaFin").datepicker();
    $("#txtFechaInicio").val(ObtenerFecha());
    $("#txtFechaFin").val(ObtenerFecha());
  

    //OBTENER PROVEEDORES
    jQuery.ajax({
        url: $.MisUrls.url._ObtenerProveedores,
        type: "GET",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            $("#cboProveedor").LoadingOverlay("hide");
            $("#cboProveedor").html("");

            $("<option>").attr({ "value": 0 }).text("-- Seleccionar todas--").appendTo("#cboProveedor");
            if (data.data != null)
                $.each(data.data, function (i, item) {

                    if (item.Activo == true) {
                        $("<option>").attr({ "value": item.IdProveedor }).text(item.RazonSocial).appendTo("#cboProveedor");
                    }
                })
        },
        error: function (error) {
            console.log(error)
        },
        beforeSend: function () {
            $("#cboProveedor").LoadingOverlay("show");
        },
    });



    //OBTENER TIENDAS
    jQuery.ajax({
        url: $.MisUrls.url._ObtenerTiendas,
        type: "GET",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {

            $("#cboTienda").LoadingOverlay("hide");
            $("#cboTienda").html("");

            $("<option>").attr({ "value": 0 }).text("-- Seleccionar todas--").appendTo("#cboTienda");
            if (data.data != null)
                $.each(data.data, function (i, item) {

                    if (item.Activo == true) {
                        $("<option>").attr({ "value": item.IdTienda }).text(item.Nombre).appendTo("#cboTienda");
                    }
                })
        },
        error: function (error) {
            console.log(error)
        },
        beforeSend: function () {
            $("#cboTienda").LoadingOverlay("show");
        },
    });




    tabladata = $('#tbCompras').DataTable({
        "ajax": {
            "url": $.MisUrls.url._ObtenerCompras + "?fechainicio=" + ObtenerFecha() + "&fechafin=" + ObtenerFecha() + "&idproveedor=0&idtienda=0",
            "type": "GET",
            "datatype": "json"
        },
        "columns": [
            {
                "data": "IdCompra", render: function (data) {
                    return "<button class='btn btn-success btn-sm ml-2' type='button' onclick='Imprimir(" + data + ")'><i class='far fa-clipboard'></i> Ver</button>"
                }
            },
            { 
                "data": "IdCompra",
                render: function (data) {
                    return '<span class="badge badge-primary">#' + data + '</span>';
                }
            },
            {
                "data": "oProveedor", render: function (data) {
                    return data.RazonSocial
                }
            },
            {
                "data": "oTienda", render: function (data) {
                    return data.Nombre
                }
            },
            { "data": "FechaCompra" },
            {
                "data": "TotalCosto", render: function (data) {
                    // Formatear como $X.XXX,XX (punto para miles, coma para decimales)
                    var numero = parseFloat(data).toFixed(2);
                    var partes = numero.split('.');
                    var entero = partes[0].replace(/\B(?=(\d{3})+(?!\d))/g, ".");
                    var decimal = partes[1];
                    return "$" + entero + "," + decimal;
                }
            },
            {
                "data": "CantidadProductos",
                render: function (data) {
                    return '<span class="badge badge-info">' + data + '</span>';
                }
            },
            {
                "data": "Productos",
                render: function (data) {
                    if (!data || data == '') return '<em class="text-muted">Sin productos</em>';
                    // Limitar a 100 caracteres para que no sea muy largo
                    if (data.length > 100) {
                        return '<span title="' + data + '">' + data.substring(0, 100) + '...</span>';
                    }
                    return data;
                }
            },
            {
                "data": null,
                render: function (data, type, row) {
                    var selectedAbierta = row.Estado == 'Abierta' ? 'selected' : '';
                    var selectedCerrada = row.Estado == 'Cerrada' ? 'selected' : '';
                    var colorClass = row.Estado == 'Abierta' ? 'bg-warning' : 'bg-success text-white';
                    
                    return '<select class="form-control form-control-sm select-estado ' + colorClass + '" data-id="' + row.IdCompra + '" style="width:110px;">' +
                           '<option value="Abierta" ' + selectedAbierta + '>Abierta</option>' +
                           '<option value="Cerrada" ' + selectedCerrada + '>Cerrada</option>' +
                           '</select>';
                },
                "orderable": false
            }

        ],
        "language": {
            "url": $.MisUrls.url.Url_datatable_spanish
        },
        "order": [[1, "desc"]], // Orden por defecto: ID descendente (mas recientes primero)
        responsive: true
    });

    // Evento para cambiar orden de la tabla
    $('#cboOrden').on('change', function () {
        var orden = $(this).val(); // 'asc' o 'desc'
        
        if (orden == 'asc') {
            tabladata.order([[1, 'asc']]).draw(); // Mas antiguos primero
        } else {
            tabladata.order([[1, 'desc']]).draw(); // Mas recientes primero
        }
    });

    // Evento para cambiar estado de Orden de Compra automaticamente
    $('#tbCompras tbody').on('change', '.select-estado', function () {
        var $select = $(this);
        var idCompra = $select.data('id');
        var nuevoEstado = $select.val();
        var estadoAnterior = $select.find('option').not(':selected').val();
        
        // Mostrar loading en el select
        $select.prop('disabled', true);
        
        jQuery.ajax({
            url: $.MisUrls.url._ActualizarEstadoOC,
            type: "POST",
            data: JSON.stringify({ idCompra: idCompra, estado: nuevoEstado }),
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                $select.prop('disabled', false);
                if (data.resultado) {
                    // Cambiar color del select segun el estado
                    if (nuevoEstado == 'Abierta') {
                        $select.removeClass('bg-success text-white').addClass('bg-warning');
                    } else {
                        $select.removeClass('bg-warning').addClass('bg-success text-white');
                    }
                    
                    swal("Exito", "Estado actualizado a: " + nuevoEstado, "success");
                } else {
                    // Revertir seleccion si falla
                    $select.val(estadoAnterior);
                    swal("Error", "No se pudo actualizar el estado", "error");
                }
            },
            error: function (error) {
                $select.prop('disabled', false);
                $select.val(estadoAnterior);
                swal("Error", "Error al actualizar el estado", "error");
            }
        });
    });

})


function buscar() {

    if ($("#txtFechaInicio").val().trim() == "" || $("#txtFechaFin").val().trim() == "") {
        swal("Mensaje", "Debe ingresar fechas", "warning")
        return;
    }

    tabladata.ajax.url($.MisUrls.url._ObtenerCompras + "?"+
        "fechainicio=" + $("#txtFechaInicio").val().trim() +
        "&fechafin=" + $("#txtFechaFin").val().trim() +
        "&idproveedor=" + $("#cboProveedor").val() +
        "&idtienda=" + $("#cboTienda").val()).load();
}

function ObtenerFecha() {

    var d = new Date();
    var month = d.getMonth() + 1;
    var day = d.getDate();
    var output = (('' + day).length < 2 ? '0' : '') + day + '/' + (('' + month).length < 2 ? '0' : '') + month + '/' + d.getFullYear();

    return output;
}


function Imprimir(id) {
    var texto = $.MisUrls.url._DocumentoCompra + "?idcompra=" + id;

    // Open the page in a new tab or window
    var w = window.open(texto);

    //w.onload = function () {
    //    w.print();
    //}

}