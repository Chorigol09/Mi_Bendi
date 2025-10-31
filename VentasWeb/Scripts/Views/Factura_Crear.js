
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

    // Establecer fecha actual por defecto
    var hoy = new Date();
    var dia = String(hoy.getDate()).padStart(2, '0');
    var mes = String(hoy.getMonth() + 1).padStart(2, '0');
    var anio = hoy.getFullYear();
    $('#txtFechaFactura').val(anio + '-' + mes + '-' + dia);

    //OBTENER PROVEEDORES
    try {
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
    } catch (e) {
        console.error('Error al inicializar tabla de proveedores:', e);
    }

    //OBTENER TIENDAS
    try {
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
    } catch (e) {
        console.error('Error al inicializar tabla de tiendas:', e);
    }

    //OBTENER PRODUCTOS
    try {
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
                        return data ? data.Descripcion : ''
                    }
                }

            ],
            "language": {
                "url": $.MisUrls.url.Url_datatable_spanish
            },
            responsive: true
        });
    } catch (e) {
        console.error('Error al inicializar tabla de productos:', e);
    }

    // Registrar evento del botón Guardar Factura
    $('#btnTerminarGuardarFactura').on('click', function () {

        if ($('#tbFactura > tbody  > tr').length == 0) {
            swal("Mensaje", "No existen detalles", "warning")
            return;
        }

        // Verificar si solo está la fila de total (sin productos reales)
        var filasSinTotal = $('#tbFactura > tbody > tr').not('#totalGeneralRow').length;
        if (filasSinTotal == 0) {
            swal("Mensaje", "Debe agregar al menos un producto", "warning")
            return;
        }

        if (parseInt($("#txtIdProveedor").val()) == 0) {
            swal("Mensaje", "Debe seleccionar un proveedor", "warning")
            return;
        }

        if (parseInt($("#txtIdTienda").val()) == 0) {
            swal("Mensaje", "Debe seleccionar una tienda", "warning")
            return;
        }

        if ($("#txtNumeroFactura").val().trim() == "") {
            swal("Mensaje", "Debe ingresar el número de factura", "warning")
            return;
        }

        var $xml = "";
        var factura = "";
        var detallefactura = ""
        var detalle = "";
        var totalfactura = 0;
        var numeroOrdenCompra = $("#txtNumeroOrdenCompra").length > 0 ? $("#txtNumeroOrdenCompra").val().trim() : "";

        $xml = "<DETALLE>";
        factura = "<FACTURA>" +
            "<IdProveedor>" + $("#txtIdProveedor").val() + "</IdProveedor>" +
            "<NumeroFactura>" + $("#txtNumeroFactura").val().trim() + "</NumeroFactura>" +
            "<NumeroOrdenCompra>" + (numeroOrdenCompra || "No asociado a una OC") + "</NumeroOrdenCompra>" +
            "<FechaEmision>" + $("#txtFechaFactura").val() + "</FechaEmision>" +
            "<Total>¡totalfactura!</Total>" +
            "</FACTURA>";
        detallefactura = "<DETALLE_FACTURA>"

        $('#tbFactura > tbody  > tr').each(function (index, tr) {

            var fila = tr;
            // Saltar la fila del total general
            if ($(fila).attr('id') === 'totalGeneralRow') {
                return true; // continue
            }
            
            var idproducto = parseFloat($(fila).find("td.codigoproducto").data("idproducto"));
            var cantidad = parseFloat($(fila).find("td.cantidad").text());
            var preciounitario = parseFloat($(fila).find("td.preciounitario").data("precio"));
            var subtotal = parseFloat(cantidad) * parseFloat(preciounitario);

            detalle = detalle + "<DETALLE>" +
                "<IdFactura>0</IdFactura>" +
                "<IdProducto>" + idproducto + "</IdProducto>" +
                "<Cantidad>" + cantidad + "</Cantidad>" +
                "<PrecioUnitario>" + preciounitario.toFixed(2) + "</PrecioUnitario>" +
                "<Subtotal>" + subtotal.toFixed(2) + "</Subtotal>" +
                "</DETALLE>";
            totalfactura = totalfactura + subtotal;

        });

        // Asegurar formato decimal correcto (punto como separador)
        factura = factura.replace("¡totalfactura!", totalfactura.toFixed(2));
        $xml = $xml + factura + detallefactura + detalle + "</DETALLE_FACTURA></DETALLE>";

        // Debug: mostrar XML en consola
        console.log("XML a enviar:", $xml);
        console.log("Total factura:", totalfactura.toFixed(2));

        jQuery.ajax({
            url: $.MisUrls.url._GuardarFacturaConDetalles,
            type: "POST",
            data: { xml: $xml },
            dataType: "json",
            success: function (data) {
                $.LoadingOverlay("hide");
                
                console.log("Respuesta del servidor:", data);

                if (data.resultado) {
                    // Mensaje simplificado
                    var mensaje = "Factura registrada exitosamente\n\n";
                    mensaje += "Número: " + $("#txtNumeroFactura").val() + "\n";
                    mensaje += "Proveedor: " + $("#txtRazonSocialProveedor").val() + "\n";
                    mensaje += "Tienda: " + $("#txtNombreTienda").val() + "\n";
                    mensaje += "TOTAL: " + formatearPrecio(totalfactura) + "\n";
                    mensaje += "Estado: PENDIENTE DE PAGO";

                    //PROVEEDOR
                    $("#txtIdProveedor").val("0");
                    $("#txtRucProveedor").val("");
                    $("#txtRazonSocialProveedor").val("");

                    //TIENDA
                    $("#txtIdTienda").val("0");
                    $("#txtRucTienda").val("");
                    $("#txtNombreTienda").val("");

                    //NUMERO FACTURA, ORDEN COMPRA Y FECHA
                    $("#txtNumeroFactura").val("");
                    $("#txtNumeroOrdenCompra").val("");
                    // Restablecer fecha actual
                    var hoy = new Date();
                    var dia = String(hoy.getDate()).padStart(2, '0');
                    var mes = String(hoy.getMonth() + 1).padStart(2, '0');
                    var anio = hoy.getFullYear();
                    $('#txtFechaFactura').val(anio + '-' + mes + '-' + dia);

                    //PRODUCTO
                    $("#txtIdProducto").val("0");
                    $("#txtCodigoProducto").val("");
                    $("#txtNombreProducto").val("");
                    $("#txtCantidadProducto").val("0");
                    $("#txtPrecioUnitario").val("$0,00");

                    $("#tbFactura tbody").html("");
                    
                    // Desbloquear cabecera para nueva factura
                    desbloquearCabecera();

                    // Mostrar mensaje de éxito
                    swal("Factura Registrada", mensaje, "success");
                } else {

                    swal("Mensaje", "No se pudo registrar la factura", "warning")
                }
            },
            error: function (error) {
                console.log("Error completo:", error);
                console.log("Status:", error.status);
                console.log("Response:", error.responseText);
                $.LoadingOverlay("hide");
                swal("Error", "Error al registrar la factura: " + (error.responseText || error.statusText), "error")
            },
            beforeSend: function () {
                $.LoadingOverlay("show");
            },
        });

    });

})

// Función para bloquear campos de cabecera
function bloquearCabecera() {
    $('#btnBuscarProveedor').prop('disabled', true);
    $('#btnBuscarTienda').prop('disabled', true);
    $('#txtNumeroFactura').prop('readonly', true);
    $('#txtFechaFactura').prop('readonly', true);
    
    // Agregar clase visual de bloqueado
    $('#btnBuscarProveedor').addClass('disabled');
    $('#btnBuscarTienda').addClass('disabled');
    $('#txtNumeroFactura').addClass('bg-light');
    $('#txtFechaFactura').addClass('bg-light');
}

// Función para desbloquear campos de cabecera
function desbloquearCabecera() {
    $('#btnBuscarProveedor').prop('disabled', false);
    $('#btnBuscarTienda').prop('disabled', false);
    $('#txtNumeroFactura').prop('readonly', false);
    $('#txtFechaFactura').prop('readonly', false);
    
    // Remover clase visual de bloqueado
    $('#btnBuscarProveedor').removeClass('disabled');
    $('#btnBuscarTienda').removeClass('disabled');
    $('#txtNumeroFactura').removeClass('bg-light');
    $('#txtFechaFactura').removeClass('bg-light');
}

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
$("#txtPrecioUnitario").on('input', function() {
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
$("#txtPrecioUnitario").on('focus', function() {
    if ($(this).val() === '$0,00') {
        $(this).val('');
    }
});

// Al perder el foco, completar con ,00 si no tiene decimales
$("#txtPrecioUnitario").on('blur', function() {
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



$('#btnAgregarProducto').on('click', function () {

    var existe_codigo = false;
    if (
        parseInt($("#txtIdProveedor").val()) == 0 ||
        parseInt($("#txtIdTienda").val()) == 0 ||
        $("#txtNumeroFactura").val().trim() == "" ||
        $("#txtFechaFactura").val().trim() == "" ||
        parseInt($("#txtIdProducto").val()) == 0 ||
        parseFloat($("#txtCantidadProducto").val()) == 0 ||
        desformatearPrecio($("#txtPrecioUnitario").val()) == 0
    ) {
        swal("Mensaje", "Debe completar todos los campos (proveedor, número, fecha, tienda y producto)", "warning")
        return;
    }

    $('#tbFactura > tbody  > tr').each(function (index, tr) {
        var fila = tr;
        var codigoproducto = $(fila).find("td.codigoproducto").text();

        if (codigoproducto == $("#txtCodigoProducto").val()) {
            existe_codigo = true;
            return false;
        }

    });

    if (!existe_codigo) {
        var cantidad = parseFloat($("#txtCantidadProducto").val());
        var precioUnitario = desformatearPrecio($("#txtPrecioUnitario").val());
        var total = cantidad * precioUnitario;

        $("<tr>").append(
            $("<td>").append(
                $("<button>").addClass("btn btn-danger btn-sm").text("Eliminar")
            ),
            $("<td>").addClass("codigoproducto").data("idproducto", $("#txtIdProducto").val()).append($("#txtCodigoProducto").val()),
            $("<td>").append($("#txtNombreProducto").val()),
            $("<td>").addClass("cantidad text-right").append(cantidad),
            $("<td>").addClass("preciounitario text-right").data("precio", precioUnitario).append(formatearPrecio(precioUnitario)),
            $("<td>").addClass("totalproducto text-right").data("total", total).append(formatearPrecio(total))
        ).appendTo("#tbFactura tbody");

        // BLOQUEAR CAMPOS DE CABECERA al agregar el primer producto
        bloquearCabecera();

        // Actualizar total general
        actualizarTotalGeneral();

        $("#txtIdProducto").val("0");
        $("#txtCodigoProducto").val("");
        $("#txtNombreProducto").val("");
        $("#txtCantidadProducto").val("0");
        $("#txtPrecioUnitario").val("$0,00");

    } else {
        swal("Mensaje", "El producto ya existe en la factura", "warning")
    }
})

$('#tbFactura tbody').on('click', 'button[class="btn btn-danger btn-sm"]', function () {
    $(this).parents("tr").remove();
    actualizarTotalGeneral();
    
    // DESBLOQUEAR CAMPOS si no quedan productos (excluyendo la fila de total)
    var cantidadProductos = $('#tbFactura > tbody > tr').length;
    // Restar 1 si existe la fila de total
    if ($('#totalGeneralRow').length > 0) {
        cantidadProductos--;
    }
    
    if (cantidadProductos == 0) {
        desbloquearCabecera();
    }
})

// Función para actualizar el total general
function actualizarTotalGeneral() {
    var totalGeneral = 0;
    $('#tbFactura > tbody > tr').each(function() {
        var total = parseFloat($(this).find('td.totalproducto').data('total')) || 0;
        totalGeneral += total;
    });
    
    // Actualizar o crear fila de total
    $('#totalGeneralRow').remove();
    if ($('#tbFactura > tbody > tr').length > 0) {
        $("<tr id='totalGeneralRow'>").append(
            $("<td colspan='5' class='text-right'>").html("<strong>TOTAL FACTURA:</strong>"),
            $("<td colspan='1' class='text-right'>").html("<strong>" + formatearPrecio(totalGeneral) + "</strong>")
        ).appendTo("#tbFactura tbody");
    }
}
