console.log("✅ Producto_Asignar.js v1.0 cargado - Con formateo de precios corregido");

var tabladata;
var tablatienda;
var tablaproducto;


$(document).ready(function () {
    activarMenu("Compras");


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


    tablatienda = $('#tbTienda').DataTable({
        "ajax": {
            "url": $.MisUrls.url._ObtenerTiendas,
            "type": "GET",
            "datatype": "json"
        },
        "columns": [
            {
                "data": "IdTienda", "render": function (data, type, row, meta) {
                    return "<button class='btn btn-sm btn-primary ml-2' type='button' onclick='tiendaSelect(" + JSON.stringify(row) + ")'><i class='fas fa-check'></i></button>" 
                },
                "orderable": false,
                "searchable": false,
                "width": "90px"
            },
            { "data": "RUC" },
            { "data": "Nombre" },
            { "data": "Direccion" }

        ],
        "language": {
            "url": $.MisUrls.url.Url_datatable_spanish
        },
        responsive: true
    });

    tablaproducto = $('#tbProducto').DataTable({
        "ajax": {
            "url": $.MisUrls.url._ObtenerProductos,
            "type": "GET",
            "datatype": "json"
        },
        "columns": [
            {
                "data": "IdProducto", "render": function (data, type, row, meta) {
                    return "<button class='btn btn-sm btn-primary ml-2' type='button' onclick='productoSelect(" + JSON.stringify(row) + ")'><i class='fas fa-check'></i></button>"
                },
                "orderable": false,
                "searchable": false,
                "width": "90px"
            },
            { "data": "Codigo" },
            { "data": "Nombre" },
            { "data": "Descripcion" },
            {
                "data": "oCategoria", render: function (data) {
                    return data.Descripcion
                }
            }

        ],
        "language": {
            "url": $.MisUrls.url.Url_datatable_spanish
        },
        responsive: true
    });


    tabladata = $('#tbdata').DataTable({
        "ajax": {
            "url": $.MisUrls.url._ObtenerAsignaciones,
            "type": "GET",
            "datatype": "json"
        },
        "columns": [
            { "data": "oTienda", render: function (data) { return data.Nombre   } },
            { "data": "oTienda", render: function (data) { return data.RUC   } },
            { "data": "oProducto", render: function (data) { return data.Codigo   } },
            { "data": "oProducto", render: function (data) { return data.Nombre   } },
            { "data": "Stock" },
            { 
                "data": "PrecioUnidadVenta", 
                "render": function (data) { 
                    if (data && data > 0) {
                        // Formatear como $X.XXX,XX (punto para miles, coma para decimales)
                        var numero = parseFloat(data).toFixed(2);
                        var partes = numero.split('.');
                        var entero = partes[0].replace(/\B(?=(\d{3})+(?!\d))/g, ".");
                        var decimal = partes[1];
                        return "$" + entero + "," + decimal;
                    }
                    return '<span class="text-muted">Sin precio</span>';
                }
            },
            {
                "data": null, 
                "render": function (data, type, row, meta) {
                    return "<button class='btn btn-warning btn-sm' type='button' onclick='abrirModalPrecio(" + JSON.stringify(row) + ")'><i class='fas fa-edit'></i> Modificar</button>"
                },
                "orderable": false,
                "searchable": false,
                "width": "120px"
            },
            {
                "data": "IdProductoTienda", "render": function (data, type, row, meta) {
                    return  "<button class='btn btn-danger btn-sm ml-2' type='button' onclick='eliminar(" + data + ")'><i class='fa fa-trash'></i></button>"
                },
                "orderable": false,
                "searchable": false,
                "width": "80px"
            }

        ],
        "language": {
            "url": $.MisUrls.url.Url_datatable_spanish
        },
        responsive: true
    });

})

// Formatear precio en tiempo real en el modal
$(document).on('input', '#txtNuevoPrecioVenta', function() {
    var input = $(this);
    var valor = input.val();
    
    // Remover todo excepto números y coma
    var limpio = valor.replace(/[^0-9,]/g, '');
    
    // Si está vacío, mostrar $0,00
    if (limpio === '' || limpio === '0') {
        input.val('$0,00');
        return;
    }
    
    // Separar parte entera y decimal si hay coma
    var partes = limpio.split(',');
    var parteEntera = partes[0];
    var parteDecimal = partes[1] || '';
    
    // Limitar decimales a 2 dígitos
    if (parteDecimal.length > 2) {
        parteDecimal = parteDecimal.substring(0, 2);
    }
    
    // Agregar separador de miles a la parte entera
    if (parteEntera.length > 0) {
        parteEntera = parteEntera.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    }
    
    // Construir valor formateado
    var valorFormateado = '$' + (parteEntera || '0');
    if (limpio.includes(',')) {
        valorFormateado += ',' + parteDecimal;
    }
    
    input.val(valorFormateado);
});

// Al enfocar, si es $0,00 limpiar el campo
$(document).on('focus', '#txtNuevoPrecioVenta', function() {
    if ($(this).val() === '$0,00') {
        $(this).val('');
    }
});

// Al perder el foco, completar con ,00 si no tiene decimales
$(document).on('blur', '#txtNuevoPrecioVenta', function() {
    var valor = $(this).val();
    if (valor === '' || valor === '$') {
        $(this).val('$0,00');
        return;
    }
    
    // Si no tiene decimales, agregar ,00
    if (!valor.includes(',')) {
        $(this).val(valor + ',00');
    } else {
        // Si tiene coma pero no tiene 2 decimales, completar
        var partes = valor.split(',');
        if (partes[1] && partes[1].length === 1) {
            $(this).val(valor + '0');
        } else if (partes[1] && partes[1].length === 0) {
            $(this).val(valor + '00');
        }
    }
});

function buscarTienda() {
    tablatienda.ajax.reload();
    $('#modalTienda').modal('show');
}

function buscarProducto(){
    tablaproducto.ajax.reload();
    $('#modalProducto').modal('show');
}

function tiendaSelect(json) {
    $("#txtIdTienda").val(json.IdTienda);
    $("#txtRuc").val(json.RUC);
    $("#txtRazonSocial").val(json.Nombre);
    $("#txtDireccion").val(json.Direccion);

    $('#modalTienda').modal('hide');
}

function productoSelect(json) {
    $("#txtIdProducto").val(json.IdProducto);
    $("#txtCodigo").val(json.Codigo);
    $("#txtNombre").val(json.Nombre);
    $("#txtDescripcion").val(json.Descripcion);

    $('#modalProducto').modal('hide');
}

$("#txtCodigo").on('keypress', function (e) {

    if (e.which == 13) {
        
        //OBTENER PRODUCTOS
        jQuery.ajax({
            url: $.MisUrls.url._ObtenerProductos,
            type: "GET",
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                $("#txtCodigo").LoadingOverlay("hide");
                var encontrado = false;
                if (data.data != null) {
                    $.each(data.data, function (i, item) {
                        if (item.Activo == true && item.Codigo == $("#txtCodigo").val()) {

                            $("#txtIdProducto").val(item.IdProducto);
                            $("#txtCodigo").val(item.Codigo);
                            $("#txtNombre").val(item.Nombre);
                            $("#txtDescripcion").val(item.Descripcion);

                            encontrado = true;
                            return false;
                        }
                    })

                    if (!encontrado) {
                        $("#txtIdProducto").val("0");
                        $("#txtNombre").val("");
                        $("#txtDescripcion").val("");
                    }
                }

            },
            error: function (error) {
                console.log(error)
            },
            beforeSend: function () {
                $("#txtCodigo").LoadingOverlay("show");
            },
        });


    }
});


function asignarProducto() {

    var camposvacios = false;

    if ($("#txtIdTienda").val() == "0" || $("#txtIdProducto").val() == "0")
        camposvacios = true;

    if (!camposvacios) {

        var request = {
            objeto: {
                oProducto: { IdProducto: parseInt($("#txtIdProducto").val()) },
                oTienda: { IdTienda: parseInt($("#txtIdTienda").val()) },
            }
        }

        jQuery.ajax({
            url: $.MisUrls.url._RegistrarProductoTienda,
            type: "POST",
            data: JSON.stringify(request),
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {

                if (data.resultado) {
                    tabladata.ajax.reload();
                    $("#txtIdProducto").val("0");
                    $("#txtCodigo").val("");
                    $("#txtNombre").val("");
                    $("#txtDescripcion").val("");
                } else {

                    swal("Mensaje", "No se pudo registrar la asignacion", "warning")
                }
            },
            error: function (error) {
                console.log(error)
            },
            beforeSend: function () {

            },
        });

    } else {
        swal("Mensaje!", "Es necesario completar todos los campos", "warning")
    }


}

// Funciones de formateo de precios (formato argentino: $X.XXX,XX)
function formatearPrecio(valor) {
    if (valor == null || valor === '') return '$0,00';
    var numero = parseFloat(valor);
    if (isNaN(numero)) return '$0,00';
    
    var partes = numero.toFixed(2).split('.');
    var entero = partes[0].replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    var decimal = partes[1];
    return '$' + entero + ',' + decimal;
}

function desformatearPrecio(valor) {
    if (!valor) return 0;
    // Remover $, puntos (separador de miles) y reemplazar coma por punto
    var limpio = valor.toString().replace(/\$/g, '').replace(/\./g, '').replace(',', '.');
    var numero = parseFloat(limpio);
    return isNaN(numero) ? 0 : numero;
}

function abrirModalPrecio(row) {
    $("#txtIdProductoTiendaPrecio").val(row.IdProductoTienda);
    $("#txtProductoNombrePrecio").val(row.oProducto.Nombre);
    $("#txtTiendaNombrePrecio").val(row.oTienda.Nombre);
    $("#txtNuevoPrecioVenta").val(formatearPrecio(row.PrecioUnidadVenta || 0));
    $('#modalPrecio').modal('show');
}

function guardarPrecioVenta() {
    var idProductoTienda = $("#txtIdProductoTiendaPrecio").val();
    var valorFormateado = $("#txtNuevoPrecioVenta").val();
    var nuevoPrecio = desformatearPrecio(valorFormateado);

    console.log("Valor en campo:", valorFormateado);
    console.log("Valor desformateado:", nuevoPrecio);

    if (!nuevoPrecio || parseFloat(nuevoPrecio) < 0) {
        swal("Mensaje", "Por favor ingrese un precio valido", "warning");
        return;
    }

    var request = {
        idProductoTienda: parseInt(idProductoTienda),
        precioVenta: parseFloat(nuevoPrecio)
    };
    
    console.log("Request a enviar:", request);

    jQuery.ajax({
        url: $.MisUrls.url._ActualizarPrecioVentaTienda,
        type: "POST",
        data: JSON.stringify(request),
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.resultado) {
                swal("Exito", "Precio de venta actualizado correctamente", "success");
                $('#modalPrecio').modal('hide');
                tabladata.ajax.reload();
            } else {
                swal("Error", "No se pudo actualizar el precio de venta", "error");
            }
        },
        error: function (error) {
            console.log(error);
            swal("Error", "Error al actualizar el precio", "error");
        }
    });
}

function eliminar($id) {

    swal({
        title: "Mensaje",
        text: "¿Desea eliminar la asignacion?",
        type: "warning",
        showCancelButton: true,

        confirmButtonText: "Si",
        confirmButtonColor: "#DD6B55",

        cancelButtonText: "No",

        closeOnConfirm: true
    },

        function () {
            jQuery.ajax({
                url: $.MisUrls.url._EliminarProductoTienda + "?id=" + $id,
                type: "GET",
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function (data) {

                    if (data.resultado) {
                        tabladata.ajax.reload();
                    } else {
                        swal("Mensaje", "No se pudo eliminar la asignacion?", "warning")
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