
var tabladata;
var tablaproveedor;
var tablatienda;
var tablaproducto;

// Función para formatear precio en formato argentino: $1.200,00
function formatearPrecio(valor) {
    if (!valor || isNaN(valor)) return '$0,00';
    var numero = parseFloat(valor);
    var partes = numero.toFixed(2).split('.');
    partes[0] = partes[0].replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    return '$' + partes[0] + ',' + partes[1];
}

// Función para convertir formato argentino a número
function desformatearPrecio(valor) {
    if (!valor) return 0;
    // Remover $ y espacios
    valor = valor.toString().replace(/\$/g, '').replace(/\s/g, '');
    // Remover puntos (separador de miles)
    valor = valor.replace(/\./g, '');
    // Reemplazar coma por punto (separador decimal)
    valor = valor.replace(/,/g, '.');
    return parseFloat(valor) || 0;
}


$(document).ready(function () {
    activarMenu("Compras");

    //OBTENER PROVEEDORES
    tablaproveedor = $('#tbProveedor').DataTable({
        "ajax": {
            "url": $.MisUrls.url._ObtenerProveedores,
            "type": "GET",
            "datatype": "json"
        },
        "columns": [
            {
                "data": "IdProveedor", "render": function (data, type, row, meta) {
                    return "<button class='btn btn-sm btn-primary ml-2' type='button' onclick='proveedorSelect(" + JSON.stringify(row) + ")'><i class='fas fa-check'></i></button>"
                },
                "orderable": false,
                "searchable": false,
                "width": "90px"
            },
            { "data": "Ruc" },
            { "data": "RazonSocial" },
            { "data": "Direccion" }

        ],
        "language": {
            "url": $.MisUrls.url.Url_datatable_spanish
        },
        responsive: true
    });

    //OBTENER TIENDAS
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

    //OBTENER PRODUCTOS
    tablaproducto = $('#tbProducto').DataTable({
        "ajax": {
            "url": $.MisUrls.url._ObtenerProductosPorTienda + "?IdTienda=0",
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

})

function buscarProveedor() {
    tablaproveedor.ajax.reload();
    $('#modalProveedor').modal('show');
}


function buscarTienda() {
    tablatienda.ajax.reload();
    $('#modalTienda').modal('show');
}

function buscarProducto() {
    if (parseInt($("#txtIdTienda").val()) == 0) {
        swal("Mensaje", "Debe seleccionar una tienda primero", "warning")
        return;
    }
    tablaproducto.ajax.url($.MisUrls.url._ObtenerProductosPorTienda + "?IdTienda=" + $("#txtIdTienda").val()).load();

    $('#modalProducto').modal('show');
}

function proveedorSelect(json) {

    $("#txtIdProveedor").val(json.IdProveedor);
    $("#txtRucProveedor").val(json.Ruc);
    $("#txtRazonSocialProveedor").val(json.RazonSocial);

    $('#modalProveedor').modal('hide');
}

function tiendaSelect(json) {
    $("#txtIdTienda").val(json.IdTienda);
    $("#txtRucTienda").val(json.RUC);
    $("#txtNombreTienda").val(json.Nombre);

    $('#modalTienda').modal('hide');
}

function productoSelect(json) {
    $("#txtIdProducto").val(json.IdProducto);
    $("#txtCodigoProducto").val(json.Codigo);
    $("#txtNombreProducto").val(json.Nombre);

    $('#modalProducto').modal('hide');
}



$("#txtCodigoProducto").on('keypress', function (e) {

    if (e.which == 13) {
        
        //OBTENER PRODUCTOS
        jQuery.ajax({
            url: $.MisUrls.url._ObtenerProductos,
            type: "GET",
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                $("#txtCodigoProducto").LoadingOverlay("hide");
                var encontrado = false;
                if (data.data != null) {
                    $.each(data.data, function (i, item) {
                        if (item.Activo == true && item.Codigo == $("#txtCodigoProducto").val()) {

                            $("#txtIdProducto").val(item.IdProducto);
                            $("#txtCodigoProducto").val(item.Codigo);
                            $("#txtNombreProducto").val(item.Nombre);

                            encontrado = true;
                            return false;
                        }
                    })

                    if (!encontrado) {
                        $("#txtIdProducto").val("0");
                        $("#txtNombreProducto").val("");
                    }
                }
            },
            error: function (error) {
                console.log(error)
            },
            beforeSend: function () {
                $("#txtCodigoProducto").LoadingOverlay("show");
            },
        });


    }
});

$.fn.inputFilter = function (inputFilter) {
    return this.on("input keydown keyup mousedown mouseup select contextmenu drop", function () {
        if (inputFilter(this.value)) {
            this.oldValue = this.value;
            this.oldSelectionStart = this.selectionStart;
            this.oldSelectionEnd = this.selectionEnd;
        } else if (this.hasOwnProperty("oldValue")) {
            this.value = this.oldValue;
            this.setSelectionRange(this.oldSelectionStart, this.oldSelectionEnd);
        } else {
            this.value = "";
        }
    });
};

$("#txtCantidadProducto").inputFilter(function (value) {
    return /^-?\d*$/.test(value);
});

// Limpiar el campo de cantidad cuando se hace clic y tiene valor 0
$("#txtCantidadProducto").on('focus', function() {
    if ($(this).val() === '0') {
        $(this).val('');
    }
});

// Si el campo queda vacío al salir, volver a poner 0
$("#txtCantidadProducto").on('blur', function() {
    if ($(this).val() === '') {
        $(this).val('0');
    }
});

// Formatear precio en tiempo real - el usuario solo escribe números
$("#txtPrecioCompraProducto").on('input', function() {
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
$("#txtPrecioCompraProducto").on('focus', function() {
    if ($(this).val() === '$0,00') {
        $(this).val('');
    }
});

// Al perder el foco, completar con ,00 si no tiene decimales
$("#txtPrecioCompraProducto").on('blur', function() {
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



$('#btnAgregarCompra').on('click', function () {

    var existe_codigo = false;
    if (
        parseInt($("#txtIdProveedor").val()) == 0 ||
        parseInt($("#txtIdTienda").val()) == 0 ||
        parseInt($("#txtIdProducto").val()) == 0 ||
        parseFloat($("#txtCantidadProducto").val()) == 0 ||
        desformatearPrecio($("#txtPrecioCompraProducto").val()) == 0
    ) {
        swal("Mensaje", "Debe completar todos los campos", "warning")
        return;
    }

    $('#tbCompra > tbody  > tr').each(function (index, tr) {
        var fila = tr;
        var codigoproducto = $(fila).find("td.codigoproducto").text();

        if (codigoproducto == $("#txtCodigoProducto").val()) {
            existe_codigo = true;
            return false;
        }

    });

    if (!existe_codigo) {
        var cantidad = parseFloat($("#txtCantidadProducto").val());
        var precioUnitario = desformatearPrecio($("#txtPrecioCompraProducto").val());
        var total = cantidad * precioUnitario;

        $("<tr>").append(
            $("<td>").append(
                $("<button>").addClass("btn btn-danger btn-sm").text("Eliminar")
            ),
            $("<td>").append($("#txtRucProveedor").val()),
            $("<td>").append($("#txtRucTienda").val()),
            $("<td>").addClass("codigoproducto").data("idproducto", $("#txtIdProducto").val()).append($("#txtCodigoProducto").val()),
            $("<td>").append($("#txtNombreProducto").val()),
            $("<td>").addClass("cantidad").append(cantidad),
            $("<td>").addClass("preciocompra").data("precio", precioUnitario).append(formatearPrecio(precioUnitario)),
            $("<td>").addClass("totalproducto").data("total", total).append(formatearPrecio(total))
        ).appendTo("#tbCompra tbody");

        // Actualizar total general
        actualizarTotalGeneral();

        $("#txtIdProducto").val("0");
        $("#txtCodigoProducto").val("");
        $("#txtNombreProducto").val("");
        $("#txtCantidadProducto").val("0");
        $("#txtPrecioCompraProducto").val("$0,00");

    } else {
        swal("Mensaje", "El producto ya existe en la compra", "warning")
    }
})

$('#tbCompra tbody').on('click', 'button[class="btn btn-danger btn-sm"]', function () {
    $(this).parents("tr").remove();
    actualizarTotalGeneral();
})

// Función para actualizar el total general
function actualizarTotalGeneral() {
    var totalGeneral = 0;
    $('#tbCompra > tbody > tr').each(function() {
        var total = parseFloat($(this).find('td.totalproducto').data('total')) || 0;
        totalGeneral += total;
    });
    
    // Actualizar o crear fila de total
    $('#totalGeneralRow').remove();
    if ($('#tbCompra > tbody > tr').length > 0) {
        $("<tr id='totalGeneralRow'>").append(
            $("<td colspan='7' class='text-right'>").html("<strong>TOTAL GENERAL:</strong>"),
            $("<td colspan='1'>").html("<strong>" + formatearPrecio(totalGeneral) + "</strong>")
        ).appendTo("#tbCompra tbody");
    }
}



$('#btnTerminarGuardarCompra').on('click', function () {


    if ($('#tbCompra > tbody  > tr').length == 0) {
        swal("Mensaje", "No existen detalles", "warning")
        return;
    }

    var $xml = "";
    var compra = "";
    var detallecompra = ""
    var detalle = "";
    var totalcostocompra = 0;

    $xml = "<DETALLE>";
    compra = "<COMPRA>" +
        "<IdUsuario>!idusuario¡</IdUsuario>" +
        "<IdProveedor>" + $("#txtIdProveedor").val() + "</IdProveedor>" +
        "<IdTienda>" + $("#txtIdTienda").val() + "</IdTienda>" +
        "<TotalCosto>!totalcosto¡</TotalCosto>" +
        "</COMPRA>";
    detallecompra = "<DETALLE_COMPRA>"

    $('#tbCompra > tbody  > tr').each(function (index, tr) {

        var fila = tr;
        // Saltar la fila del total general
        if ($(fila).attr('id') === 'totalGeneralRow') {
            return true; // continue
        }
        
        var idproducto = parseFloat($(fila).find("td.codigoproducto").data("idproducto"));
        var cantidad = parseFloat($(fila).find("td.cantidad").text());
        var preciocompra = parseFloat($(fila).find("td.preciocompra").data("precio"));
        var totalcosto = parseFloat(cantidad) * parseFloat(preciocompra);

        // Debug: verificar valores
        console.log("Producto ID:", idproducto);
        console.log("Cantidad:", cantidad);
        console.log("Precio Compra:", preciocompra);
        console.log("Total Costo:", totalcosto);

        detalle = detalle + "<DETALLE>" +
            "<IdCompra>0</IdCompra>" +
            "<IdProducto>" + idproducto + "</IdProducto>" +
            "<Cantidad>" + cantidad + "</Cantidad>" +
            "<PrecioUnidadCompra>" + preciocompra.toFixed(2) + "</PrecioUnidadCompra>" +
            "<PrecioUnidadVenta>0</PrecioUnidadVenta>" +
            "<TotalCosto>" + totalcosto.toFixed(2) + "</TotalCosto>" +
            "</DETALLE>";
        totalcostocompra = totalcostocompra + totalcosto;

    });

    // Asegurar formato decimal correcto (punto como separador)
    compra = compra.replace("!totalcosto¡", totalcostocompra.toFixed(2));
    $xml = $xml + compra + detallecompra + detalle + "</DETALLE_COMPRA></DETALLE>";

    // Debug: verificar total
    console.log("Total Costo Compra:", totalcostocompra.toFixed(2));
    console.log("XML a enviar:", $xml);

    jQuery.ajax({
        url: $.MisUrls.url._GuardarCompra,
        type: "POST",
        data: { xml: $xml },
        dataType: "json",
        success: function (data) {
            $.LoadingOverlay("hide");

            if (data.resultado) {
                // Construir mensaje con detalles
                var mensaje = "Orden de compra registrada exitosamente\n\n";
                mensaje += "Proveedor: " + $("#txtRazonSocialProveedor").val() + "\n";
                mensaje += "Tienda: " + $("#txtNombreTienda").val() + "\n\n";
                mensaje += "Detalle de productos:\n";
                
                $('#tbCompra > tbody > tr').each(function() {
                    if ($(this).attr('id') !== 'totalGeneralRow') {
                        var codigo = $(this).find('td.codigoproducto').text();
                        var nombre = $(this).find('td').eq(4).text();
                        var cantidad = $(this).find('td.cantidad').text();
                        var precio = $(this).find('td.preciocompra').text();
                        var total = $(this).find('td.totalproducto').text();
                        mensaje += "• " + nombre + " (" + codigo + ")\n";
                        mensaje += "  Cantidad: " + cantidad + " | Precio Unit.: " + precio + " | Total: " + total + "\n";
                    }
                });
                
                mensaje += "\nTOTAL: " + formatearPrecio(totalcostocompra);

                //PROVEEDOR
                $("#txtIdProveedor").val("0");
                $("#txtRucProveedor").val("");
                $("#txtRazonSocialProveedor").val("");

                //TIENDA
                $("#txtIdTienda").val("0");
                $("#txtRucTienda").val("");
                $("#txtNombreTienda").val("");

                //PRODUCTO
                $("#txtIdProducto").val("0");
                $("#txtCodigoProducto").val("");
                $("#txtNombreProducto").val("");
                $("#txtCantidadProducto").val("0");
                $("#txtPrecioCompraProducto").val("$0,00");

                $("#tbCompra tbody").html("");

                swal("Orden de Compra Registrada", mensaje, "success")
            } else {

                swal("Mensaje", "No se pudo registrar la compra", "warning")
            }
        },
        error: function (error) {
            console.log(error)
        },
        beforeSend: function () {
            $.LoadingOverlay("show");
        },
    });

 

})
