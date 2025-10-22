console.log("✅ Venta_Crear.js v2.1 cargado - Con formateo completo: precios, cantidad y monto de pago");

var tablaproducto;
var tablacliente;


$(document).ready(function () {

    activarMenu("Ventas");
    $("#txtproductocantidad").val("0");
    $("#txtfechaventa").val(ObtenerFecha());


    //OBTENER PROVEEDORES
    jQuery.ajax({
        url: $.MisUrls.url._ObtenerUsuario,
        type: "GET",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            //TIENDA
            $("#txtIdTienda").val(data.oTienda.IdTienda);
            $("#lbltiendanombre").text(data.oTienda.Nombre);
            $("#lbltiendaruc").text(data.oTienda.RUC);
            $("#lbltiendadireccion").text(data.oTienda.Direccion);

            //USUARIO
            $("#txtIdUsuario").val(data.IdUsuario);
            $("#lblempleadonombre").text(data.Nombres);
            $("#lblempleadoapellido").text(data.Apellidos);
            $("#lblempleadocorreo").text(data.Correo);
        },
        error: function (error) {
            console.log(error)
        },
        beforeSend: function () {
            $("#cboProveedor").LoadingOverlay("show");
        },
    });


    //OBTENER PRODUCTOS
    tablaproducto = $('#tbProducto').DataTable({
        "ajax": {
            "url": $.MisUrls.url._ObtenerProductoStockPorTienda + "?IdTienda=0",
            "type": "GET",
            "datatype": "json"
        },
        "columns": [
            {
                "data": "IdProductoTienda", "render": function (data, type, row, meta) {
                    return "<button class='btn btn-sm btn-primary ml-2' type='button' onclick='productoSelect(" + JSON.stringify(row) + ")'><i class='fas fa-check'></i></button>"
                },
                "orderable": false,
                "searchable": false,
                "width": "90px"
            },
            {
                "data": "oProducto", render: function (data) {
                    return data.Codigo
                }
            },
            {
                "data": "oProducto", render: function (data) {
                    return data.Nombre
                }
            },
            {
                "data": "oProducto", render: function (data) {
                    return data.Descripcion
                }
            },
            { "data": "Stock" }

        ],
        "language": {
            "url": $.MisUrls.url.Url_datatable_spanish
        },
        responsive: true
    });

    tablacliente = $('#tbcliente').DataTable({
        "ajax": {
            "url": $.MisUrls.url._ObtenerClientes,
            "type": "GET",
            "datatype": "json"
        },
        "columns": [
            {
                "data": "IdCliente", "render": function (data, type, row, meta) {
                    return "<button class='btn btn-sm btn-primary ml-2' type='button' onclick='clienteSelect(" + JSON.stringify(row) + ")'><i class='fas fa-check'></i></button>"
                },
                "orderable": false,
                "searchable": false,
                "width": "90px"
            },
            { "data": "TipoDocumento" },
            { "data": "NumeroDocumento" },
            { "data": "Nombre" },
            { "data": "Direccion" }
        ],
        "language": {
            "url": $.MisUrls.url.Url_datatable_spanish
        },
        responsive: true
    });

})

function ObtenerFecha() {

    var d = new Date();
    var month = d.getMonth() + 1;
    var day = d.getDate();
    var output = (('' + day).length < 2 ? '0' : '') + day + '/' + (('' + month).length < 2 ? '0' : '') + month + '/' + d.getFullYear();

    return output;
}


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

$("#txtproductocantidad").inputFilter(function (value) {
    return /^-?\d*$/.test(value);
});

// Limpiar el campo de cantidad cuando se hace clic y tiene valor 0
$("#txtproductocantidad").on('focus', function() {
    if ($(this).val() === '0') {
        $(this).val('');
    }
});

// Si el campo queda vacío al salir, volver a poner 0
$("#txtproductocantidad").on('blur', function() {
    if ($(this).val() === '') {
        $(this).val('0');
    }
});

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

// Formatear monto de pago en tiempo real
$("#txtmontopago").on('input', function() {
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
$("#txtmontopago").on('focus', function() {
    if ($(this).val() === '$0,00') {
        $(this).val('');
    }
});

// Al perder el foco, completar con ,00 si no tiene decimales
$("#txtmontopago").on('blur', function() {
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

$('#btnBuscarProducto').on('click', function () {

  
    tablaproducto.ajax.url($.MisUrls.url._ObtenerProductoStockPorTienda + "?IdTienda=" + parseInt($("#txtIdTienda").val()) ).load();

    $('#modalProducto').modal('show');
})

$('#btnBuscarCliente').on('click', function () {

    tablacliente.ajax.reload();

    $('#modalCliente').modal('show');
})

function productoSelect(json) {
    $("#txtIdProducto").val(json.oProducto.IdProducto);
    $("#txtproductocodigo").val(json.oProducto.Codigo);
    $("#txtproductonombre").val(json.oProducto.Nombre);
    $("#txtproductodescripcion").val(json.oProducto.Descripcion);
    $("#txtproductostock").val(json.Stock);
    $("#txtproductoprecio").val(formatearPrecio(json.PrecioUnidadVenta));
    $("#txtproductocantidad").val("0");
    $('#modalProducto').modal('hide');
}

function clienteSelect(json) {

    $("#cboclientetipodocumento").val(json.TipoDocumento);
    $("#txtclientedocumento").val(json.NumeroDocumento);
    $("#txtclientenombres").val(json.Nombre);
    $("#txtclientedireccion").val(json.Direccion);
    $("#txtclientetelefono").val(json.Telefono);
    $('#modalCliente').modal('hide');
}

$("#txtproductocodigo").on('keypress', function (e) {


    if (e.which == 13) {

        var request = { IdTienda: parseInt($("#txtIdTienda").val()) }


        //OBTENER PROVEEDORES
        jQuery.ajax({
            url: $.MisUrls.url._ObtenerProductoStockPorTienda + "?IdTienda=" + parseInt($("#txtIdTienda").val()),
            type: "GET",
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {

                var encontrado = false;
                if (data.data != null) {
                    $.each(data.data, function (i, item) {
                        if (item.oProducto.Codigo == $("#txtproductocodigo").val()) {

                            $("#txtIdProducto").val(item.oProducto.IdProducto);
                            $("#txtproductocodigo").val(item.oProducto.Codigo);
                            $("#txtproductonombre").val(item.oProducto.Nombre);
                            $("#txtproductodescripcion").val(item.oProducto.Descripcion);
                            $("#txtproductostock").val(item.Stock);
                            $("#txtproductoprecio").val(formatearPrecio(item.PrecioUnidadVenta));
                            encontrado = true;
                            return false;
                        }
                    })

                    if (!encontrado) {

                        $("#txtIdProducto").val("0");
                        $("#txtproductocodigo").val("");
                        $("#txtproductonombre").val("");
                        $("#txtproductodescripcion").val("");
                        $("#txtproductostock").val("");
                        $("#txtproductoprecio").val("");
                        $("#txtproductocantidad").val("0");

                    }
                }

            },
            error: function (error) {
                console.log(error)
            },
            beforeSend: function () {
                $("#cboProveedor").LoadingOverlay("show");
            },
        });



    }
});


$('#btnAgregar').on('click', function () {

    $("#txtproductocantidad").val($("#txtproductocantidad").val() == "" ? "0" : $("#txtproductocantidad").val());

    var existe_codigo = false;
    if (
        parseInt($("#txtIdProducto").val()) == 0 ||
        parseFloat($("#txtproductocantidad").val()) == 0
    ) {
        swal("Mensaje", "Debe completar todos los campos del producto", "warning")
        return;
    }

    $('#tbVenta > tbody  > tr').each(function (index, tr) {
        var fila = tr;
        var idproducto = $(fila).find("td.producto").data("idproducto");

        if (idproducto == $("#txtIdProducto").val()) {
            existe_codigo = true;
            return false;
        }

    });

    if (!existe_codigo) {

        controlarStock(parseInt($("#txtIdProducto").val()), parseInt($("#txtIdTienda").val()), parseInt($("#txtproductocantidad").val()), true);

        var precioUnitario = desformatearPrecio($("#txtproductoprecio").val());
        var cantidad = parseFloat($("#txtproductocantidad").val());
        var importetotal = precioUnitario * cantidad;
        
        $("<tr>").append(
            $("<td>").append(
                $("<button>").addClass("btn btn-danger btn-sm").text("Eliminar").data("idproducto", parseInt($("#txtIdProducto").val())).data("cantidadproducto", parseInt($("#txtproductocantidad").val()))
            ),
            $("<td>").addClass("productocantidad").text(cantidad),
            $("<td>").addClass("producto").data("idproducto", $("#txtIdProducto").val()).text($("#txtproductonombre").val()),
            $("<td>").text($("#txtproductodescripcion").val()),
            $("<td>").addClass("productoprecio").data("precio", precioUnitario).text(formatearPrecio(precioUnitario)),
            $("<td>").addClass("importetotal").data("total", importetotal).text(formatearPrecio(importetotal))
        ).appendTo("#tbVenta tbody");

        $("#txtIdProducto").val("0");
        $("#txtproductocodigo").val("");
        $("#txtproductonombre").val("");
        $("#txtproductodescripcion").val("");
        $("#txtproductostock").val("");
        $("#txtproductoprecio").val("");
        $("#txtproductocantidad").val("0");

        $("#txtproductocodigo").focus();

        calcularPrecios();
    } else {
        swal("Mensaje", "El producto ya existe en la venta", "warning")
    }
})

$('#tbVenta tbody').on('click', 'button[class="btn btn-danger btn-sm"]', function () {
    var idproducto = $(this).data("idproducto");
    var cantidadproducto = $(this).data("cantidadproducto");

    controlarStock(idproducto, parseInt($("#txtIdTienda").val()), cantidadproducto, false);
    $(this).parents("tr").remove();

    calcularPrecios();
})

$('#btnTerminarGuardarVenta').on('click', function () {

    //VALIDACIONES DE CLIENTE
    if ($("#txtclientedocumento").val().trim() == "" || $("#txtclientenombres").val().trim() == "") {
        swal("Mensaje", "Complete los datos del cliente", "warning");
        return;
    }
    //VALIDACIONES DE PRODUCTOS
    if ($('#tbVenta tbody tr').length == 0) {
        swal("Mensaje", "Debe registrar minimo un producto en la venta", "warning");
        return;
    }

    //VALIDACIONES DE MONTO PAGO
    if ($("#txtmontopago").val().trim() == "") {
        swal("Mensaje", "Ingrese el monto de pago", "warning");
        return;
    }

    var $totalproductos = 0;
    var $totalimportes = 0;

    var DETALLE = "";
    var VENTA = "";
    var DETALLE_CLIENTE = "";
    var DETALLE_VENTA = "";
    var DATOS_VENTA = "";

    calcularCambio();

    $('#tbVenta > tbody  > tr').each(function (index, tr) {
        var fila = tr;
        var productocantidad = parseInt($(fila).find("td.productocantidad").text());
        var idproducto = $(fila).find("td.producto").data("idproducto");
        var productoprecio = parseFloat($(fila).find("td.productoprecio").data("precio"));
        var importetotal = parseFloat($(fila).find("td.importetotal").data("total"));

        $totalproductos = $totalproductos + productocantidad;
        $totalimportes = $totalimportes + importetotal;

        DATOS_VENTA = DATOS_VENTA + "<DATOS>" +
            "<IdVenta>0</IdVenta >" +
            "<IdProducto>" + idproducto + "</IdProducto>" +
            "<Cantidad>" + productocantidad + "</Cantidad>" +
            "<PrecioUnidad>" + productoprecio.toFixed(2) + "</PrecioUnidad>" +
            "<ImporteTotal>" + importetotal.toFixed(2) + "</ImporteTotal>" +
            "</DATOS>"
    });


    VENTA = "<VENTA>" +
        "<IdTienda>" + $("#txtIdTienda").val() + "</IdTienda>" +
        "<IdUsuario>" + $("#txtIdUsuario").val() + "</IdUsuario>" +
        "<IdCliente>0</IdCliente>" +
        "<TipoDocumento>" + $("#cboventatipodocumento").val() + "</TipoDocumento>" +
        "<CantidadProducto>" + $('#tbVenta tbody tr').length + "</CantidadProducto>" +
        "<CantidadTotal>" + $totalproductos + "</CantidadTotal>" +
        "<TotalCosto>" + $totalimportes.toFixed(2) + "</TotalCosto>" +
        "<ImporteRecibido>" + desformatearPrecio($("#txtmontopago").val()).toFixed(2) + "</ImporteRecibido>" +
        "<ImporteCambio>" + desformatearPrecio($("#txtcambio").val()).toFixed(2) + "</ImporteCambio>" +
        "</VENTA >";

    DETALLE_CLIENTE = "<DETALLE_CLIENTE><DATOS>" +
        "<TipoDocumento>" + $("#cboclientetipodocumento").val() + "</TipoDocumento>" +
        "<NumeroDocumento>" + $("#txtclientedocumento").val() + "</NumeroDocumento>" +
        "<Nombre>" + $("#txtclientenombres").val() + "</Nombre>" +
        "<Direccion>" + $("#txtclientedireccion").val() + "</Direccion>" +
        "<Telefono>" + $("#txtclientetelefono").val() + "</Telefono>" +
        "</DATOS></DETALLE_CLIENTE>";

    DETALLE_VENTA = "<DETALLE_VENTA>" + DATOS_VENTA + "</DETALLE_VENTA>";

    DETALLE = "<DETALLE>" + VENTA + DETALLE_CLIENTE + DETALLE_VENTA + "</DETALLE>"


    var request = { xml: DETALLE };

    jQuery.ajax({
        url: $.MisUrls.url._RegistrarVenta,
        type: "POST",
        data: JSON.stringify(request),
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {

            $(".card-venta").LoadingOverlay("hide");

            if (data.estado) {
                //DOCUMENTO
                $("#cboventatipodocumento").val("Boleta");

                //CLIENTE
                $("#cboclientetipodocumento").val("DNI");
                $("#txtclientedocumento").val("");
                $("#txtclientenombres").val("");
                $("#txtclientedireccion").val("");
                $("#txtclientetelefono").val("");


                //PRODUCTO
                $("#txtIdProducto").val("0");
                $("#txtproductocodigo").val("");
                $("#txtproductonombre").val("");
                $("#txtproductodescripcion").val("");
                $("#txtproductostock").val("");
                $("#txtproductoprecio").val("");
                $("#txtproductocantidad").val("0");

                //PRECIOS
                $("#txtsubtotal").val("0");
                $("#txtigv").val("0");
                $("#txttotal").val("0");
                $("#txtmontopago").val("");
                $("#txtcambio").val("");


                $("#tbVenta tbody").html("");

                // Mostrar mensaje de éxito y abrir PDF cuando se cierre el mensaje
                var url = $.MisUrls.url._DocumentoVenta + "?IdVenta=" + data.valor;
                
                swal({
                    title: "¡Éxito!",
                    text: "La venta se registró correctamente. ¿Desea ver el PDF?",
                    type: "success",
                    showCancelButton: true,
                    confirmButtonText: "Sí, ver PDF",
                    cancelButtonText: "No, continuar"
                }, function(isConfirm) {
                    if (isConfirm) {
                        // Abrir PDF en nueva ventana
                        window.open(url, '_blank');
                    }
                });


            } else {
                swal("Mensaje", "No se pudo registrar la venta", "warning")
            }
        },
        error: function (error) {
            console.log(error)
            $(".card-venta").LoadingOverlay("hide");
        },
        beforeSend: function () {
            $(".card-venta").LoadingOverlay("show");
        }
    });

   

})

function calcularCambio() {
    var montopago = desformatearPrecio($("#txtmontopago").val().trim());
    var totalcosto = desformatearPrecio($("#txttotal").val().trim());
    var cambio = 0;
    cambio = (montopago <= totalcosto ? totalcosto : montopago) - totalcosto;

    $("#txtcambio").val(formatearPrecio(cambio));
}

$('#btncalcular').on('click', function () {
    calcularCambio();
})


function calcularPrecios() {
    var subtotal = 0;
    var igv = 0;
    var sumatotal = 0;
    $('#tbVenta > tbody  > tr').each(function (index, tr) {
        var fila = tr;
        var importetotal = parseFloat($(fila).find("td.importetotal").data("total"));
        sumatotal = sumatotal + importetotal;
    });
    igv = sumatotal * 0.18;
    subtotal = sumatotal - igv;

    $("#txtsubtotal").val(formatearPrecio(subtotal));
    $("#txtigv").val(formatearPrecio(igv));
    $("#txttotal").val(formatearPrecio(sumatotal));
}




function controlarStock($idproducto, $idtienda, $cantidad, $restar) {
    var request = {
        idproducto: $idproducto,
        idtienda: $idtienda,
        cantidad: $cantidad,
        restar: $restar
    }


    jQuery.ajax({
        url: $.MisUrls.url._ControlarStockProducto,
        type: "POST",
        data: JSON.stringify(request),
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
           
        },
        error: function (error) {
            console.log(error)
        },
        beforeSend: function () {
        },
    });

  
}


window.onbeforeunload = function () {
    if ($('#tbVenta tbody tr').length > 0) {

        $('#tbVenta > tbody  > tr').each(function (index, tr) {
            var fila = tr;
            var productocantidad = parseInt($(fila).find("td.productocantidad").text());
            var idproducto = $(fila).find("td.producto").data("idproducto");

            controlarStock(parseInt(idproducto), parseInt($("#txtIdTienda").val()), parseInt(productocantidad), false);
        });
    }
};
