var tabladata;
var facturaSeleccionada = null;

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
        facturaSeleccionada = null;
        $("#btnGuardarOrdenPago").prop("disabled", true);
        $("#divMetodoPago").hide();
        $("#cboMetodoPago").val("0");
        
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
        responsive: true,
        paging: false,
        searching: false,
        info: false,
        ordering: false,
        autoWidth: false,
        data: [], // Inicializar vacio
        "columns": [
            {
                "defaultContent": '<button class="btn btn-primary btn-sm btn-seleccionar"><i class="fas fa-check"></i> Seleccionar</button>',
                "orderable": false,
                "searchable": false,
                "width": "100px"
            },
            { 
                "data": "NumeroFactura",
                "defaultContent": ""
            },
            { 
                "data": "NombreProveedor",
                "defaultContent": ""
            },
            { 
                "data": "TextoFechaEmision",
                "defaultContent": ""
            },
            { 
                "data": "Productos",
                "defaultContent": "Sin productos",
                "render": function (data) {
                    if (data && data.length > 40) {
                        return data.substring(0, 40) + '...';
                    }
                    return data || 'Sin productos';
                }
            },
            { 
                "data": "Cantidad",
                "defaultContent": "0",
                "className": "text-center"
            },
            { 
                "data": "MontoTotal",
                "defaultContent": "0.00",
                "className": "text-right",
                "render": function (data) {
                    return 'AR$ ' + parseFloat(data || 0).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
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
        if ($(this).val() != "0" && facturaSeleccionada != null) {
            $("#btnGuardarOrdenPago").prop("disabled", false);
        } else {
            $("#btnGuardarOrdenPago").prop("disabled", true);
        }
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
            swal("Error", "No se pudieron cargar las facturas. Revisa la consola (F12) para mas detalles.", "error");
        }
    });
}

// SELECCIONAR FACTURA
$('#tbFacturasPendientes tbody').on('click', '.btn-seleccionar', function () {
    var filaSeleccionada = $(this).closest('tr');
    var data = tabladata.row(filaSeleccionada).data();
    
    facturaSeleccionada = data;
    
    // Resaltar fila seleccionada
    $('#tbFacturasPendientes tbody tr').removeClass('table-active');
    filaSeleccionada.addClass('table-active');
    
    // Mostrar informacion de la factura seleccionada
    $("#spanFacturaSeleccionada").text(data.NumeroFactura);
    $("#spanMontoSeleccionado").text("AR$ " + parseFloat(data.MontoTotal).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,'));
    
    // Mostrar seccion de metodo de pago
    $("#divMetodoPago").slideDown();
    $("#cboMetodoPago").val("0");
    $("#btnGuardarOrdenPago").prop("disabled", true);
    
    // Scroll suave hacia el metodo de pago
    $('html, body').animate({
        scrollTop: $("#divMetodoPago").offset().top - 100
    }, 500);
});

// GUARDAR ORDEN DE PAGO
$("#btnGuardarOrdenPago").click(function () {
    if (facturaSeleccionada == null) {
        swal("Mensaje", "Debe seleccionar una factura", "warning");
        return;
    }
    
    if ($("#cboMetodoPago").val() == "0") {
        swal("Mensaje", "Debe seleccionar un metodo de pago", "warning");
        return;
    }

    var request = {
        IdFactura: facturaSeleccionada.IdFactura,
        IdProveedor: parseInt($("#cboProveedor").val()),
        MetodoPago: $("#cboMetodoPago").val(),
        MontoTotal: facturaSeleccionada.MontoTotal
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
                swal({
                    title: "Exito",
                    text: data.mensaje,
                    icon: "success",
                    button: "Aceptar"
                }).then(() => {
                    // Ocultar seccion de metodo de pago
                    $("#divMetodoPago").hide();
                    $("#cboMetodoPago").val("0");
                    
                    // Recargar facturas pendientes del mismo proveedor
                    var idProveedor = $("#cboProveedor").val();
                    facturaSeleccionada = null;
                    cargarFacturasPendientes(idProveedor);
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
