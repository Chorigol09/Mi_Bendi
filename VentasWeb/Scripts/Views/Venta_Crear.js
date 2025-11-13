console.log("✅ Venta_Crear.js v2.1 cargado - Con formateo completo: precios, cantidad y monto de pago");

var tablaproducto;
var tablacliente;


$(document).ready(function () {

    activarMenu("Ventas");
    $("#txtproductocantidad").val("0");
    $("#txtfechaventa").val(ObtenerFecha());

    // CARGAR LISTAS DE PRECIOS
    cargarListasPrecios();


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


    //OBTENER PRODUCTOS - Inicializar sin datos
    tablaproducto = $('#tbProducto').DataTable({
        "data": [], // Iniciar con array vacío
        "columns": [
            {
                "data": "IdProductoTienda", 
                "defaultContent": "",
                "render": function (data, type, row, meta) {
                    if (!data) return "";
                    return "<button class='btn btn-sm btn-primary ml-2' type='button' onclick='productoSelect(" + JSON.stringify(row) + ")'><i class='fas fa-check'></i></button>"
                },
                "orderable": false,
                "searchable": false,
                "width": "90px"
            },
            {
                "data": "oProducto",
                "defaultContent": "",
                "render": function (data) {
                    return data ? data.Codigo : "";
                }
            },
            {
                "data": "oProducto",
                "defaultContent": "",
                "render": function (data) {
                    return data ? data.Nombre : "";
                }
            },
            {
                "data": "oProducto",
                "defaultContent": "",
                "render": function (data) {
                    return data ? data.Descripcion : "";
                }
            },
            { 
                "data": "Stock",
                "defaultContent": ""
            },
            {
                "data": "PrecioVenta",
                "defaultContent": "$0,00",
                "render": function (data) {
                    return data ? formatearPrecio(data) : "$0,00";
                }
            }

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

    // Validar selección de lista de precios al cambiar
    $('#cboListaPrecio').on('change', function() {
        var idLista = $(this).val();
        if (idLista == '0') {
            // Limpiar productos si cambia la lista
            if ($('#tbVenta tbody tr').length > 0) {
                swal({
                    title: "Advertencia",
                    text: "Al cambiar la lista de precios se borrarán los productos agregados. ¿Desea continuar?",
                    type: "warning",
                    showCancelButton: true,
                    confirmButtonText: "Sí, cambiar",
                    cancelButtonText: "Cancelar"
                }, function(isConfirm) {
                    if (isConfirm) {
                        $('#tbVenta tbody').html('');
                        calcularPrecios();
                    } else {
                        // Revertir cambio
                        $('#cboListaPrecio').val($('#cboListaPrecio').data('ultimaLista') || '0');
                    }
                });
            }
        } else {
            $('#cboListaPrecio').data('ultimaLista', idLista);
        }
    });

    // Manejar cambio de método de pago
    $('#cboMetodoPago').on('change', function() {
        var metodoPago = $(this).val();
        
        if (metodoPago === 'Efectivo') {
            // Mostrar campos de monto y cambio
            $('#seccionEfectivo').show();
        } else {
            // Ocultar campos de monto y cambio para otros métodos
            $('#seccionEfectivo').hide();
            // Limpiar valores
            $('#txtmontopago').val('');
            $('#txtcambio').val('');
        }
    });

})

function cargarListasPrecios() {
    jQuery.ajax({
        url: '/ListaPrecio/ObtenerListasPreciosActivas',
        type: "GET",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.data && data.data.length > 0) {
                var combo = $("#cboListaPrecio");
                combo.empty();
                combo.append('<option value="0">-- Seleccionar Lista --</option>');
                $.each(data.data, function (i, item) {
                    combo.append('<option value="' + item.IdListaPrecio + '">' + item.Nombre + ' (' + item.TipoLista + ')</option>');
                });
            }
        },
        error: function (error) {
            console.log(error);
            swal("Error", "No se pudieron cargar las listas de precios", "error");
        }
    });
}

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
    var idListaPrecio = parseInt($("#cboListaPrecio").val());
    
    if (idListaPrecio == 0) {
        swal("Mensaje", "Debe seleccionar una lista de precios primero", "warning");
        return;
    }
    
    var idTienda = parseInt($("#txtIdTienda").val());
    var urlBase = window.location.protocol + "//" + window.location.host;
    
    // PRIMERO: Probar endpoint de test
    console.log('Probando conectividad con servidor...');
    $.ajax({
        url: urlBase + '/ListaPrecio/TestEndpoint',
        type: 'GET',
        dataType: 'json',
        success: function(testData) {
            console.log('✅ Test exitoso:', testData);
            
            // Si el test funciona, ahora intentar el endpoint real
            var url = urlBase + '/ListaPrecio/ObtenerProductosListaPrecioConStock';
            console.log('Cargando productos desde:', url);
            console.log('Parametros:', {idListaPrecio: idListaPrecio, idTienda: idTienda});
            
            $.ajax({
                url: url,
                type: 'GET',
                data: {
                    idListaPrecio: idListaPrecio,
                    idTienda: idTienda
                },
                dataType: 'json',
                success: function(data) {
                    console.log('Respuesta del servidor:', data);
                    
                    if (data.success === false) {
                        swal("Error", data.error || "Error al cargar productos", "error");
                        return;
                    }
                    
                    // Limpiar tabla y cargar nuevos datos
                    tablaproducto.clear();
                    
                    if (data.data && data.data.length > 0) {
                        tablaproducto.rows.add(data.data);
                        tablaproducto.draw();
                        $('#modalProducto').modal('show');
                    } else {
                        // Si no hay productos
                        tablaproducto.draw();
                        var mensaje = data.mensaje || "No hay productos disponibles en esta lista con stock";
                        swal("Informacion", mensaje, "info");
                    }
                },
                error: function(xhr, status, error) {
                    console.log('❌ Error en endpoint real:', {xhr: xhr, status: status, error: error});
                    console.log('URL intentada:', url);
                    console.log('Status Code:', xhr.status);
                    console.log('Response Text:', xhr.responseText);
                    swal("Error", "Endpoint existe pero falla. Codigo: " + xhr.status + " - " + error, "error");
                }
            });
        },
        error: function(xhr, status, error) {
            console.log('❌ Test de conectividad falló:', {xhr: xhr, status: status, error: error});
            swal("Error Critico", "No se puede conectar con el servidor. El proyecto no se compiló correctamente. Recompila (Clean + Rebuild)!", "error");
        }
    });
})

$('#btnBuscarCliente').on('click', function () {

    tablacliente.ajax.reload();

    $('#modalCliente').modal('show');
})

function productoSelect(json) {
    var idListaPrecio = parseInt($("#cboListaPrecio").val());
    
    if (idListaPrecio == 0) {
        swal("Mensaje", "Debe seleccionar una lista de precios primero", "warning");
        return;
    }

    $("#txtIdProducto").val(json.oProducto.IdProducto);
    $("#txtproductocodigo").val(json.oProducto.Codigo);
    $("#txtproductonombre").val(json.oProducto.Nombre);
    $("#txtproductodescripcion").val(json.oProducto.Descripcion);
    $("#txtproductostock").val(json.Stock);
    $("#txtproductocantidad").val("0");
    
    // El precio ya viene de la lista seleccionada
    if (json.PrecioVenta) {
        $("#txtproductoprecio").val(formatearPrecio(json.PrecioVenta));
    } else {
        // Si por alguna razón no viene, obtenerlo
        obtenerPrecioProducto(idListaPrecio, json.oProducto.IdProducto);
    }
    
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
        var idListaPrecio = parseInt($("#cboListaPrecio").val());
        
        if (idListaPrecio == 0) {
            swal("Mensaje", "Debe seleccionar una lista de precios primero", "warning");
            return;
        }
        
        var idTienda = parseInt($("#txtIdTienda").val());
        var codigoBuscado = $("#txtproductocodigo").val();
        
        var urlBase = window.location.protocol + "//" + window.location.host;
        var url = urlBase + '/ListaPrecio/ObtenerProductosListaPrecioConStock';

        // Buscar en productos de la lista seleccionada
        jQuery.ajax({
            url: url,
            type: "GET",
            data: {
                idListaPrecio: idListaPrecio,
                idTienda: idTienda
            },
            dataType: "json",
            success: function (data) {
                var encontrado = false;
                if (data.data != null) {
                    $.each(data.data, function (i, item) {
                        if (item.oProducto.Codigo == codigoBuscado) {
                            $("#txtIdProducto").val(item.oProducto.IdProducto);
                            $("#txtproductocodigo").val(item.oProducto.Codigo);
                            $("#txtproductonombre").val(item.oProducto.Nombre);
                            $("#txtproductodescripcion").val(item.oProducto.Descripcion);
                            $("#txtproductostock").val(item.Stock);
                            
                            // Precio ya viene de la lista
                            if (item.PrecioVenta) {
                                $("#txtproductoprecio").val(formatearPrecio(item.PrecioVenta));
                            }
                            
                            encontrado = true;
                            return false;
                        }
                    });

                    if (!encontrado) {
                        swal("Mensaje", "Producto no encontrado en la lista seleccionada", "warning");
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
            error: function (xhr, status, error) {
                console.log('Error al buscar producto:', xhr, status, error);
                swal("Error", "No se pudo buscar el producto", "error");
            }
        });
    }
});


$('#btnAgregar').on('click', function () {

    $("#txtproductocantidad").val($("#txtproductocantidad").val() == "" ? "0" : $("#txtproductocantidad").val());

    // Validar lista de precios seleccionada
    if (parseInt($("#cboListaPrecio").val()) == 0) {
        swal("Mensaje", "Debe seleccionar una lista de precios", "warning");
        return;
    }

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

    //VALIDACIONES DE MONTO PAGO - Solo para efectivo
    var metodoPago = $("#cboMetodoPago").val();
    if (metodoPago === "Efectivo" && $("#txtmontopago").val().trim() == "") {
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

    // Solo calcular cambio si es efectivo
    if (metodoPago === "Efectivo") {
        calcularCambio();
    }

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


    // Determinar importeRecibido e importeCambio según método de pago
    var importeRecibido = 0;
    var importeCambio = 0;
    
    if (metodoPago === "Efectivo") {
        importeRecibido = desformatearPrecio($("#txtmontopago").val());
        importeCambio = desformatearPrecio($("#txtcambio").val());
    } else {
        // Para otros métodos de pago, el importe recibido es igual al total
        importeRecibido = $totalimportes;
        importeCambio = 0;
    }

    VENTA = "<VENTA>" +
        "<IdTienda>" + $("#txtIdTienda").val() + "</IdTienda>" +
        "<IdUsuario>" + $("#txtIdUsuario").val() + "</IdUsuario>" +
        "<IdCliente>0</IdCliente>" +
        "<IdListaPrecio>" + $("#cboListaPrecio").val() + "</IdListaPrecio>" +
        "<TipoDocumento>" + $("#cboventatipodocumento").val() + "</TipoDocumento>" +
        "<MetodoPago>" + metodoPago + "</MetodoPago>" +
        "<CantidadProducto>" + $('#tbVenta tbody tr').length + "</CantidadProducto>" +
        "<CantidadTotal>" + $totalproductos + "</CantidadTotal>" +
        "<TotalCosto>" + $totalimportes.toFixed(2) + "</TotalCosto>" +
        "<ImporteRecibido>" + importeRecibido.toFixed(2) + "</ImporteRecibido>" +
        "<ImporteCambio>" + importeCambio.toFixed(2) + "</ImporteCambio>" +
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
                //LISTA DE PRECIOS
                $("#cboListaPrecio").val("0");
                
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


function obtenerPrecioProducto(idListaPrecio, idProducto) {
    jQuery.ajax({
        url: '/ListaPrecio/ObtenerPrecioProductoVigente?idListaPrecio=' + idListaPrecio + '&idProducto=' + idProducto,
        type: "GET",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.resultado) {
                $("#txtproductoprecio").val(formatearPrecio(data.precio));
            } else {
                swal("Advertencia", data.mensaje || "El producto no tiene precio en la lista seleccionada", "warning");
                $("#txtproductoprecio").val("$0,00");
            }
        },
        error: function (error) {
            console.log(error);
            swal("Error", "No se pudo obtener el precio del producto", "error");
            $("#txtproductoprecio").val("$0,00");
        }
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
