var tabladata;
var facturasSeleccionadas = [];

$(document).ready(function () {
    activarMenu("Ordenes de Pago");

    // OBTENER PROVEEDORES
    jQuery.ajax({
        url: $.MisUrls.url._ObtenerProveedoresOrdenPago,
        type: "GET",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            $("#cboProveedor").html("");
            $("<option>").attr({ "value": 0 }).text("-- Seleccionar Proveedor --").appendTo("#cboProveedor");
            if (data.data != null) {
                $.each(data.data, function (i, item) {
                    if (item.Activo == true) {
                        $("<option>").attr({ "value": item.IdProveedor }).text(item.RazonSocial).appendTo("#cboProveedor");
                    }
                });
            }
        },
        error: function (error) {
            console.log(error);
            swal("Error", "No se pudieron cargar los proveedores", "error");
        }
    });

    // CARGAR FACTURAS PENDIENTES AL SELECCIONAR PROVEEDOR
    $("#cboProveedor").change(function () {
        var idProveedor = $(this).val();
        facturasSeleccionadas = [];
        $("#btnGuardarOrdenPago").prop("disabled", true);
        $("#divMetodoPago").hide();
        $("#cboMetodoPago").val("0");
        $("#spanFacturasSeleccionadas").text("");
        $("#spanMontoSeleccionado").text("AR$ 0,00");
        
        if (idProveedor != 0) {
            cargarFacturasPendientes(idProveedor);
        } else {
            $("#divFacturas").hide();
            if (tabladata != null) {
                tabladata.clear().draw();
            }
        }
    });

    // INICIALIZAR DATATABLE (sin datos iniciales)
    tabladata = $('#tbFacturasPendientes').DataTable({
        responsive: false,
        paging: false,
        searching: false,
        info: false,
        ordering: false,
        autoWidth: false,
        data: [], // Inicializar vacio
        "columns": [
            {
                "data": null,
                "orderable": false,
                "searchable": false,
                "width": "35px",
                "className": "text-center",
                "render": function (data, type, row) {
                    return '<input type="checkbox" class="chk-factura" data-idfactura="' + row.IdFactura + '" data-monto="' + row.MontoTotal + '">';
                }
            },
            { 
                "data": "NumeroFactura",
                "defaultContent": "",
                "width": "22%"
            },
            { 
                "data": "NombreProveedor",
                "defaultContent": "",
                "width": "38%"
            },
            { 
                "data": "TextoFechaEmision",
                "defaultContent": "",
                "width": "15%"
            },
            { 
                "data": "MontoTotal",
                "defaultContent": "0.00",
                "className": "text-right",
                "width": "20%",
                "render": function (data) {
                    var numero = parseFloat(data || 0).toFixed(2);
                    var partes = numero.split('.');
                    var entero = partes[0].replace(/\B(?=(\d{3})+(?!\d))/g, ".");
                    var decimal = partes[1];
                    return 'AR$ ' + entero + ',' + decimal;
                }
            }
        ],
        "language": {
            "emptyTable": "Seleccione un proveedor para ver sus facturas pendientes",
            "zeroRecords": "No se encontraron facturas"
        }
    });
    
    // HABILITAR BOTON AL SELECCIONAR METODO DE PAGO
    $("#cboMetodoPago").change(function () {
        var metodoPago = $(this).val();
        
        // Mostrar/ocultar campos adicionales segun metodo de pago
        if (metodoPago != "0" && metodoPago != "Efectivo") {
            $("#divCamposAdicionales").slideDown();
            
            // Cambiar etiquetas y placeholders segun metodo
            if (metodoPago == "Transferencia Bancaria" || metodoPago == "Cheque") {
                $("#lblReferencia").text("Numero de Comprobante");
                $("#txtReferencia").attr("placeholder", "Ingrese numero de comprobante");
                $("#helpReferencia").text("Numero del comprobante bancario o cheque");
            } else if (metodoPago == "Tarjeta de Credito" || metodoPago == "Tarjeta de Debito") {
                $("#lblReferencia").text("Ultimos 4 Digitos");
                $("#txtReferencia").attr("placeholder", "Ingrese ultimos 4 digitos");
                $("#txtReferencia").attr("maxlength", "4");
                $("#helpReferencia").text("Ultimos 4 digitos de la tarjeta");
            }
            
            // Deshabilitar boton hasta que se llenen los campos
            $("#btnGuardarOrdenPago").prop("disabled", true);
        } else if (metodoPago == "Efectivo") {
            $("#divCamposAdicionales").slideUp();
            $("#txtReferencia").val("");
            $("#txtNumeroTransaccion").val("");
            
            // Habilitar boton si hay facturas seleccionadas
            if (facturasSeleccionadas.length > 0) {
                $("#btnGuardarOrdenPago").prop("disabled", false);
            }
        } else {
            $("#divCamposAdicionales").slideUp();
            $("#btnGuardarOrdenPago").prop("disabled", true);
        }
    });
    
    // VALIDAR CAMPOS ADICIONALES PARA HABILITAR BOTON
    $("#txtReferencia, #txtNumeroTransaccion").on("keyup change", function() {
        var metodoPago = $("#cboMetodoPago").val();
        
        if (metodoPago != "0" && metodoPago != "Efectivo") {
            var referencia = $("#txtReferencia").val().trim();
            var numTransaccion = $("#txtNumeroTransaccion").val().trim();
            
            if (facturasSeleccionadas.length > 0 && referencia != "" && numTransaccion != "") {
                $("#btnGuardarOrdenPago").prop("disabled", false);
            } else {
                $("#btnGuardarOrdenPago").prop("disabled", true);
            }
        }
    });
    
    // MANEJAR SELECCION DE FACTURAS CON CHECKBOXES
    $(document).on('change', '.chk-factura', function () {
        actualizarFacturasSeleccionadas();
    });
});

function cargarFacturasPendientes(idProveedor) {
    console.log("Cargando facturas para proveedor ID:", idProveedor);
    console.log("URL:", $.MisUrls.url._ObtenerFacturasPendientes);
    
    jQuery.ajax({
        url: $.MisUrls.url._ObtenerFacturasPendientes,
        type: "POST",
        data: JSON.stringify({ idProveedor: idProveedor }),
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        beforeSend: function () {
            $("#divFacturas").show();
            console.log("Enviando peticion...");
        },
        success: function (data) {
            console.log("=== RESPUESTA COMPLETA ===");
            console.log("Respuesta recibida:", data);
            
            if (data.resultado) {
                tabladata.clear();
                if (data.data && data.data.length > 0) {
                    console.log("=== DATOS DE FACTURAS ===");
                    console.log("Cantidad de facturas:", data.data.length);
                    console.log("Primera factura COMPLETA:", JSON.stringify(data.data[0], null, 2));
                    console.log("Columnas disponibles:", Object.keys(data.data[0]));
                    console.log("Valores de la primera factura:");
                    for (var key in data.data[0]) {
                        console.log("  " + key + " = " + data.data[0][key]);
                    }
                    tabladata.rows.add(data.data).draw();
                } else {
                    console.log("No hay facturas para este proveedor");
                    tabladata.draw();
                    swal("Mensaje", "No hay facturas pendientes para este proveedor", "info");
                }
            } else {
                console.error("Error en resultado:", data.mensaje);
                swal("Mensaje", data.mensaje || "Error al cargar facturas", "warning");
            }
        },
        error: function (xhr, status, error) {
            console.error("Error AJAX:", status, error);
            console.error("Respuesta del servidor:", xhr.responseText);
            swal("Error", "No se pudieron cargar las facturas. Revisa la consola (F12) para mas detalles", "error");
        }
    });
}

// ACTUALIZAR FACTURAS SELECCIONADAS
function actualizarFacturasSeleccionadas() {
    facturasSeleccionadas = [];
    var montoTotal = 0;
    var numerosFacturas = [];
    
    $('.chk-factura:checked').each(function() {
        var idFactura = parseInt($(this).data('idfactura'));
        var monto = parseFloat($(this).data('monto'));
        
        facturasSeleccionadas.push(idFactura);
        montoTotal += monto;
        
        // Obtener numero de factura de la fila
        var fila = $(this).closest('tr');
        var data = tabladata.row(fila).data();
        if (data) {
            numerosFacturas.push(data.NumeroFactura);
        }
    });
    
    // Mostrar informacion de facturas seleccionadas
    if (facturasSeleccionadas.length > 0) {
        $("#spanFacturasSeleccionadas").text(numerosFacturas.join(', '));
        
        var numero = montoTotal.toFixed(2);
        var partes = numero.split('.');
        var entero = partes[0].replace(/\B(?=(\d{3})+(?!\d))/g, ".");
        var decimal = partes[1];
        $("#spanMontoSeleccionado").text("AR$ " + entero + ',' + decimal);
        
        // Mostrar seccion de metodo de pago
        if ($("#divMetodoPago").is(':hidden')) {
            $("#divMetodoPago").slideDown();
            
            // Scroll suave hacia el metodo de pago
            $('html, body').animate({
                scrollTop: $("#divMetodoPago").offset().top - 100
            }, 500);
        }
        
        // Habilitar boton si hay metodo seleccionado
        if ($("#cboMetodoPago").val() != "0") {
            $("#btnGuardarOrdenPago").prop("disabled", false);
        }
    } else {
        $("#spanFacturasSeleccionadas").text("");
        $("#spanMontoSeleccionado").text("AR$ 0,00");
        $("#divMetodoPago").hide();
        $("#cboMetodoPago").val("0");
        $("#btnGuardarOrdenPago").prop("disabled", true);
    }
}

// GUARDAR ORDEN DE PAGO
$("#btnGuardarOrdenPago").click(function () {
    if (facturasSeleccionadas.length == 0) {
        swal("Mensaje", "Debe seleccionar al menos una factura", "warning");
        return;
    }
    
    var metodoPago = $("#cboMetodoPago").val();
    
    if (metodoPago == "0") {
        swal("Mensaje", "Debe seleccionar un metodo de pago", "warning");
        return;
    }
    
    // Validar campos adicionales si no es efectivo
    var referencia = null;
    var numeroTransaccion = null;
    
    if (metodoPago != "Efectivo") {
        referencia = $("#txtReferencia").val().trim();
        numeroTransaccion = $("#txtNumeroTransaccion").val().trim();
        
        if (referencia == "") {
            swal("Mensaje", "Debe ingresar la referencia", "warning");
            $("#txtReferencia").focus();
            return;
        }
        
        if (numeroTransaccion == "") {
            swal("Mensaje", "Debe ingresar el numero de transaccion", "warning");
            $("#txtNumeroTransaccion").focus();
            return;
        }
        
        // Validar que ultimos 4 digitos sean exactamente 4 digitos
        if ((metodoPago == "Tarjeta de Credito" || metodoPago == "Tarjeta de Debito") && referencia.length != 4) {
            swal("Mensaje", "Debe ingresar exactamente 4 digitos de la tarjeta", "warning");
            $("#txtReferencia").focus();
            return;
        }
    }
    
    // Calcular monto total de facturas seleccionadas
    var montoTotal = 0;
    $('.chk-factura:checked').each(function() {
        montoTotal += parseFloat($(this).data('monto'));
    });

    var request = {
        IdsFacturas: facturasSeleccionadas,
        IdProveedor: parseInt($("#cboProveedor").val()),
        MetodoPago: metodoPago,
        MontoTotal: montoTotal,
        Referencia: referencia,
        NumeroTransaccion: numeroTransaccion
    };

    jQuery.ajax({
        url: $.MisUrls.url._RegistrarOrdenPago,
        type: "POST",
        data: JSON.stringify(request),
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        beforeSend: function () {
            $("#btnGuardarOrdenPago").prop("disabled", true).html('<i class="fas fa-spinner fa-spin"></i> Guardando...');
        },
        success: function (data) {
            $("#btnGuardarOrdenPago").prop("disabled", false).html('<i class="fas fa-save"></i> Registrar Orden de Pago');
            
            if (data.resultado) {
                console.log("Orden de pago registrada exitosamente, recargando pagina...");
                swal({
                    title: "Exito",
                    text: data.mensaje,
                    type: "success",
                    showConfirmButton: true,
                    confirmButtonText: "Aceptar",
                    closeOnConfirm: false
                }, function() {
                    console.log("Usuario acepto el mensaje, recargando...");
                    // Recargar la pagina
                    window.location.href = window.location.href;
                });
            } else {
                swal("Error", data.mensaje, "error");
            }
        },
        error: function (error) {
            $("#btnGuardarOrdenPago").prop("disabled", false).html('<i class="fas fa-save"></i> Registrar Orden de Pago');
            console.log(error);
            swal("Error", "No se pudo registrar la orden de pago", "error");
        }
    });
});
