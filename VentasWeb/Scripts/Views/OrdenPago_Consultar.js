var tabladata;

$(document).ready(function () {
    activarMenu("Ordenes de Pago");

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

    // OBTENER PROVEEDORES
    console.log("=== CARGANDO PROVEEDORES ===");
    console.log("URL configurada:", $.MisUrls.url._ObtenerProveedoresOrdenPago);
    
    $.ajax({
        url: "/OrdenPago/ObtenerProveedores",
        type: "GET",
        dataType: "json",
        success: function (data) {
            console.log("=== RESPUESTA PROVEEDORES ===");
            console.log("Data completa:", data);
            console.log("Tipo de data:", typeof data);
            console.log("Data.data:", data.data);
            
            $("#cboFiltroProveedor").html("");
            $("<option>").attr({ "value": "0" }).text("-- Todos los proveedores --").appendTo("#cboFiltroProveedor");
            
            if (data.data != null && data.data.length > 0) {
                console.log("Total proveedores:", data.data.length);
                $.each(data.data, function (i, item) {
                    console.log("Proveedor " + i + ":", item);
                    $("<option>").attr({ "value": item.IdProveedor }).text(item.RazonSocial).appendTo("#cboFiltroProveedor");
                });
                console.log("Proveedores agregados al dropdown");
            } else {
                console.warn("No hay proveedores en data.data");
            }
        },
        error: function (xhr, status, error) {
            console.error("=== ERROR AL CARGAR PROVEEDORES ===");
            console.error("Status:", status);
            console.error("Error:", error);
            console.error("Response:", xhr.responseText);
            console.error("Status code:", xhr.status);
        }
    });

    // INICIALIZAR DATATABLE
    tabladata = $('#tbOrdenesPago').DataTable({
        responsive: false,
        paging: true,
        searching: true,
        info: true,
        autoWidth: false,
        data: [],
        "columns": [
            {
                "defaultContent": '<button class="btn btn-info btn-sm btn-ver"><i class="fas fa-eye"></i></button>',
                "orderable": false,
                "searchable": false,
                "width": "70px",
                "className": "text-center"
            },
            { 
                "data": "NumeroFactura", 
                "defaultContent": "",
                "width": "20%",
                "render": function (data, type, row) {
                    if (data && data.length > 30) {
                        return '<span title="' + data + '">' + data.substring(0, 30) + '...</span>';
                    }
                    return data || '';
                }
            },
            { 
                "data": "NombreProveedor", 
                "defaultContent": "",
                "width": "22%"
            },
            { 
                "data": "CantidadFacturas",
                "defaultContent": "1",
                "className": "text-center",
                "width": "7%",
                "render": function (data) {
                    var cantidad = data || 1;
                    if (cantidad > 1) {
                        return '<span class="badge badge-primary">' + cantidad + '</span>';
                    } else {
                        return '<span class="badge badge-secondary">1</span>';
                    }
                }
            },
            { 
                "data": "FechaEmision",
                "defaultContent": "",
                "width": "10%"
            },
            { 
                "data": "MontoTotal",
                "defaultContent": "0.00",
                "className": "text-right",
                "width": "14%",
                "render": function (data) {
                    var numero = parseFloat(data || 0).toFixed(2);
                    var partes = numero.split('.');
                    var entero = partes[0].replace(/\B(?=(\d{3})+(?!\d))/g, ".");
                    var decimal = partes[1];
                    return 'AR$ ' + entero + ',' + decimal;
                }
            },
            { 
                "data": "MetodoPago", 
                "defaultContent": "",
                "width": "13%"
            },
            { 
                "data": "Estado",
                "defaultContent": "",
                "className": "text-center",
                "width": "7%",
                "render": function (data) {
                    if (data == "Pagado") {
                        return '<span class="badge badge-success">Pagado</span>';
                    } else {
                        return '<span class="badge badge-warning">' + data + '</span>';
                    }
                }
            }
        ],
        "language": {
            "emptyTable": "No hay ordenes de pago registradas",
            "zeroRecords": "No se encontraron ordenes de pago",
            "info": "Mostrando _START_ a _END_ de _TOTAL_ ordenes",
            "infoEmpty": "Mostrando 0 a 0 de 0 ordenes",
            "infoFiltered": "(filtrado de _MAX_ ordenes totales)",
            "search": "Buscar:",
            "paginate": {
                "first": "Primero",
                "last": "Ultimo",
                "next": "Siguiente",
                "previous": "Anterior"
            }
        }
    });

    // BUSCAR ORDENES DE PAGO
    $("#btnBuscar").click(function () {
    var idProveedor = $("#cboFiltroProveedor").val();
    
    console.log("Buscando ordenes para proveedor ID:", idProveedor);

    jQuery.ajax({
        url: $.MisUrls.url._ObtenerOrdenesPago,
        type: "POST",
        data: JSON.stringify({
            idProveedor: idProveedor == 0 ? null : parseInt(idProveedor)
        }),
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            console.log("Respuesta recibida:", data);
            
            if (data.resultado) {
                tabladata.clear();
                if (data.data && data.data.length > 0) {
                    tabladata.rows.add(data.data).draw();
                } else {
                    tabladata.draw();
                    var nombreProveedor = $("#cboFiltroProveedor option:selected").text();
                    if (idProveedor != 0) {
                        swal("Sin resultados", "El proveedor seleccionado no tiene ninguna Orden de Pago registrada", "info");
                    } else {
                        swal("Sin resultados", "No hay ordenes de pago registradas", "info");
                    }
                }
            } else {
                swal("Mensaje", data.mensaje, "warning");
            }
        },
        error: function (error) {
            console.error("Error:", error);
            swal("Error", "No se pudieron cargar las ordenes de pago", "error");
        }
    });
    });

    // VER COMPROBANTE DE ORDEN DE PAGO
    $('#tbOrdenesPago tbody').on('click', '.btn-ver', function () {
        var filaSeleccionada = $(this).closest('tr');
        var data = tabladata.row(filaSeleccionada).data();

        console.log("Cargando comprobante para orden:", data.IdOrdenPago);

        jQuery.ajax({
            url: $.MisUrls.url._ObtenerDetalleOrdenPago,
            type: "POST",
            data: JSON.stringify({ idOrdenPago: data.IdOrdenPago }),
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            beforeSend: function () {
                $("body").LoadingOverlay("show");
            },
            success: function (response) {
                $("body").LoadingOverlay("hide");
                if (response.resultado) {
                    var detalle = response.data;
                    console.log("Detalle recibido:", detalle);

                    // Llenar encabezado
                    $("#txtNumeroOrdenPago").text(detalle.NumeroOrdenPago);
                    
                    // Convertir fecha de registro
                    var fechaRegistro = detalle.FechaRegistro;
                    if (fechaRegistro) {
                        var fecha = new Date(parseInt(fechaRegistro.substr(6)));
                        var dia = ("0" + fecha.getDate()).slice(-2);
                        var mes = ("0" + (fecha.getMonth() + 1)).slice(-2);
                        var anio = fecha.getFullYear();
                        $("#txtFechaOrdenPago").text("Fecha - " + dia + "/" + mes + "/" + anio);
                    } else {
                        $("#txtFechaOrdenPago").text("Fecha - N/A");
                    }

                    // Detalle Proveedor
                    $("#txtRucProveedor").text(detalle.DocumentoProveedor || "N/A");
                    $("#txtRazonSocialProveedor").text(detalle.NombreProveedor);

                    // Estado
                    $("#txtEstadoPago").text(detalle.Estado);
                    if (detalle.Estado == "Pagado") {
                        $("#txtEstadoPago").css("color", "#28a745");
                    } else {
                        $("#txtEstadoPago").css("color", "#ffc107");
                    }

                    // Obtener facturas asociadas a la orden de pago
                    $.ajax({
                        url: $.MisUrls.url._ObtenerFacturasOrdenPago,
                        type: "POST",
                        data: JSON.stringify({ idOrdenPago: detalle.IdOrdenPago }),
                        dataType: "json",
                        contentType: "application/json; charset=utf-8",
                        success: function (responseFacturas) {
                            $("#tbodyDetalleFacturas").html("");
                            
                            if (responseFacturas.resultado && responseFacturas.data && responseFacturas.data.length > 0) {
                                var totalGeneral = 0;
                                
                                $.each(responseFacturas.data, function (i, factura) {
                                    // Formatear monto de factura
                                    var montoNum = parseFloat(factura.MontoFactura).toFixed(2);
                                    var montoPartes = montoNum.split('.');
                                    var montoEntero = montoPartes[0].replace(/\B(?=(\d{3})+(?!\d))/g, ".");
                                    var montoFormatado = "AR$ " + montoEntero + "," + montoPartes[1];
                                    
                                    totalGeneral += parseFloat(factura.MontoFactura);
                                    
                                    var fila = "<tr>" +
                                        "<td style='text-align: center; font-size: 14px;'>" + factura.NumeroFactura + "</td>" +
                                        "<td style='text-align: right; font-size: 14px;'>" + montoFormatado + "</td>" +
                                        "</tr>";
                                    $("#tbodyDetalleFacturas").append(fila);
                                });
                                
                                // Formatear total general
                                var totalNum = totalGeneral.toFixed(2);
                                var totalPartes = totalNum.split('.');
                                var totalEntero = totalPartes[0].replace(/\B(?=(\d{3})+(?!\d))/g, ".");
                                $("#txtTotalOrdenPago").text("AR$ " + totalEntero + "," + totalPartes[1]);
                            } else {
                                $("#tbodyDetalleFacturas").append("<tr><td colspan='2' class='text-center'>No hay facturas registradas</td></tr>");
                                $("#txtTotalOrdenPago").text("AR$ 0,00");
                            }
                        },
                        error: function (error) {
                            console.error("Error al cargar facturas:", error);
                            $("#tbodyDetalleFacturas").append("<tr><td colspan='2' class='text-center text-danger'>Error al cargar facturas</td></tr>");
                        }
                    });

                    // Metodo de Pago
                    $("#txtMetodoPago").text(detalle.MetodoPago);
                    
                    // Referencia y Numero Transaccion
                    if (detalle.MetodoPago != "Efectivo" && detalle.Referencia) {
                        $("#trNumeroTransaccion").show();
                        
                        // Cambiar etiqueta segun metodo
                        if (detalle.MetodoPago == "Transferencia Bancaria" || detalle.MetodoPago == "Cheque") {
                            $("#lblReferencia").text("Numero de Comprobante:");
                        } else if (detalle.MetodoPago == "Tarjeta de Credito" || detalle.MetodoPago == "Tarjeta de Debito") {
                            $("#lblReferencia").text("Ultimos 4 Digitos:");
                        }
                        
                        $("#txtReferencia").text(detalle.Referencia || "-");
                        $("#txtNumeroTransaccion").text(detalle.NumeroTransaccion || "-");
                    } else {
                        $("#trNumeroTransaccion").hide();
                        $("#lblReferencia").text("Referencia:");
                        $("#txtReferencia").text("-");
                        $("#txtNumeroTransaccion").text("-");
                    }

                    // Mostrar modal
                    $("#modalComprobanteOrdenPago").modal('show');
                } else {
                    swal("Mensaje", response.mensaje, "warning");
                }
            },
            error: function (error) {
                $("body").LoadingOverlay("hide");
                console.error("Error al cargar comprobante:", error);
                swal("Error", "No se pudo cargar el comprobante", "error");
            }
        });
    });
});

function ObtenerFecha() {
    var d = new Date();
    var month = d.getMonth() + 1;
    var day = d.getDate();
    var output = (('' + day).length < 2 ? '0' : '') + day + '/' + (('' + month).length < 2 ? '0' : '') + month + '/' + d.getFullYear();
    return output;
}
