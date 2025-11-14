
var tabladata;
$(document).ready(function () {
    activarMenu("Mantenedor");


    ////validamos el formulario
    $("#form").validate({
        rules: {
            Nombre: "required",
            Descripcion: "required"
        },
        messages: {
            Nombre: "(*)",
            Descripcion: "(*)"

        },
        errorElement: 'span'
    });

    //OBTENER CATEGORIAS
    jQuery.ajax({
        url: $.MisUrls.url._ObtenerCategorias,
        type: "GET",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            
            $("#cboCategoria").html("");

            if (data.data != null) {
                $.each(data.data, function (i, item) {

                    if (item.Activo == true) {
                        $("<option>").attr({ "value": item.IdCategoria }).text(item.Descripcion).appendTo("#cboCategoria");
                    }
                })
                $("#cboCategoria").val($("#cboCategoria option:first").val());
            }

        },
        error: function (error) {
            console.log(error)
        },
        beforeSend: function () {
        },
    });


    tabladata = $('#tbdata').DataTable({
        "ajax": {
            "url": $.MisUrls.url._ObtenerProductos,
            "type": "GET",
            "datatype": "json"
        },
        "columns": [
            { "data": "Codigo" },
            { "data": "Nombre" },
            { "data": "Descripcion" },
            {
                "data": "oCategoria", render: function (data) {
                    return data.Descripcion
                }
            },
            {
                "data": "Activo", "render": function (data) {
                    if (data) {
                        return '<span class="badge badge-success">Activo</span>'
                    } else {
                        return '<span class="badge badge-danger">No Activo</span>'
                    }
                }
            },
            {
                "data": "IdProducto", "render": function (data, type, row, meta) {
                    return "<button class='btn btn-primary btn-sm' type='button' onclick='abrirPopUpForm(" + JSON.stringify(row) + ")'><i class='fas fa-pen'></i></button>" +
                        "<button class='btn btn-info btn-sm ml-2' type='button' onclick='verMovimientos(" + data + ", &quot;" + row.Nombre + "&quot;)'><i class='fas fa-box'></i></button>" +
                        "<button class='btn btn-danger btn-sm ml-2' type='button' onclick='eliminar(" + data + ")'><i class='fa fa-trash'></i></button>"
                },
                "orderable": false,
                "searchable": false,
                "width": "140px"
            }

        ],
        "language": {
            "url": $.MisUrls.url.Url_datatable_spanish
        },
        responsive: true
    });


})


function abrirPopUpForm(json) {

    $("#txtid").val(0);

    if (json != null) {

        $("#txtid").val(json.IdProducto);
        
        $("#txtCodigo").val(json.Codigo);
        $("#txtNombre").val(json.Nombre);
        $("#txtDescripcion").val(json.Descripcion);
        $("#cboCategoria").val(json.IdCategoria);
        $("#cboEstado").val(json.Activo == true ? 1 : 0);
        $("#txtCodigo").prop("disabled", true)

    } else {

        $("#txtCodigo").val("AUTOGENERADO");
        $("#txtCodigo").prop("disabled", true)
        $("#txtNombre").val("");
        $("#txtDescripcion").val("");
        $("#cboCategoria").val($("#cboCategoria option:first").val());

        $("#cboEstado").val(1);
        
    }

    $('#FormModal').modal('show');

}


function Guardar() {

    if ($("#form").valid()) {

        var request = {
            objeto: {
                IdProducto: parseInt($("#txtid").val()),
                Nombre: $("#txtNombre").val(),
                Descripcion: $("#txtDescripcion").val(),
                IdCategoria: $("#cboCategoria").val(),
                Activo: ($("#cboEstado").val() == "1" ? true : false)
            }
        }

        jQuery.ajax({
            url: $.MisUrls.url._GuardarProducto,
            type: "POST",
            data: JSON.stringify(request),
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {

                if (data.resultado) {
                    tabladata.ajax.reload();
                    $('#FormModal').modal('hide');
                } else {

                    swal("Mensaje", "No se pudo guardar los cambios", "warning")
                }
            },
            error: function (error) {
                console.log(error)
            },
            beforeSend: function () {

            },
        });

    }

}


var tablaMovimientos;

function verMovimientos(idProducto, nombreProducto) {
    $('#MovimientosModal').modal('show');
    $('#modalTituloProducto').text(nombreProducto);
    
    // Destruir DataTable si ya existe
    if ($.fn.DataTable.isDataTable('#tbMovimientos')) {
        $('#tbMovimientos').DataTable().destroy();
    }
    
    // Resetear el selector a "Más recientes primero"
    $('#cboOrdenMovimientos').val('desc');
    
    // Inicializar DataTable de movimientos
    tablaMovimientos = $('#tbMovimientos').DataTable({
        "ajax": {
            "url": $.MisUrls.url._ObtenerMovimientosStock + "?idProducto=" + idProducto,
            "type": "GET",
            "datatype": "json"
        },
        "scrollX": false,
        "autoWidth": false,
        "columns": [
            { 
                "data": "FechaRegistro",
                "render": function (data, type, row) {
                    if (!data) return '-';
                    
                    // Manejar formato de fecha de .NET (/Date(...)/)
                    var fecha;
                    if (typeof data === 'string' && data.indexOf('/Date(') === 0) {
                        var timestamp = parseInt(data.replace(/\/Date\((\d+)\)\//, '$1'));
                        fecha = new Date(timestamp);
                    } else {
                        fecha = new Date(data);
                    }
                    
                    if (isNaN(fecha.getTime())) return '-';
                    
                    // Para ordenamiento, devolver timestamp
                    if (type === 'sort' || type === 'type') {
                        return fecha.getTime();
                    }
                    
                    // Para display, devolver formato legible
                    var dia = String(fecha.getDate()).padStart(2, '0');
                    var mes = String(fecha.getMonth() + 1).padStart(2, '0');
                    var anio = fecha.getFullYear();
                    var horas = String(fecha.getHours()).padStart(2, '0');
                    var minutos = String(fecha.getMinutes()).padStart(2, '0');
                    return dia + '/' + mes + '/' + anio + ' ' + horas + ':' + minutos;
                }
            },
            { 
                "data": "TipoMovimiento",
                "width": "25%"
            },
            { "data": "Tienda" },
            { 
                "data": "Cantidad",
                "render": function (data, type, row) {
                    var tipoMov = row.TipoMovimiento.toLowerCase();
                    // Determinar si es ingreso o egreso por palabras clave
                    if (tipoMov.includes('compra') || tipoMov.includes('recepcion') || 
                        tipoMov.includes('ajuste') && tipoMov.includes('suma') || 
                        tipoMov.includes('devolucion') || tipoMov.includes('ingreso')) {
                        return '<span class="text-success font-weight-bold">+' + data + '</span>';
                    } else {
                        return '<span class="text-danger font-weight-bold">-' + data + '</span>';
                    }
                }
            },
            { "data": "Motivo" },
            { "data": "Usuario" }
        ],
        "language": {
            "url": $.MisUrls.url.Url_datatable_spanish
        },
        "order": [[0, "desc"]],
        responsive: true
    });
    
    // Evento para cambiar el orden al seleccionar una opción
    $('#cboOrdenMovimientos').off('change').on('change', function() {
        var orden = $(this).val();
        if (tablaMovimientos) {
            tablaMovimientos.order([0, orden]).draw();
        }
    });
}


function eliminar($id) {

    swal({
        title: "Mensaje",
        text: "¿Desea eliminar el producto seleccionado?",
        type: "warning",
        showCancelButton: true,

        confirmButtonText: "Si",
        confirmButtonColor: "#DD6B55",

        cancelButtonText: "No",

        closeOnConfirm: true
    },

        function () {
            jQuery.ajax({
                url: $.MisUrls.url._EliminarProducto + "?id=" + $id,
                type: "GET",
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (data) {

                    if (data.resultado) {
                        tabladata.ajax.reload();
                    } else {
                        swal("Mensaje", "No se pudo eliminar el producto", "warning")
                    }
                },
                error: function (error) {
                    console.log(error)
                },
                beforeSend: function () {

                },
            });
        });

}