
var tablaMovimientos;
var tablaProductos;
var productoSeleccionado = null;
var detalleMovimiento = [];

$(document).ready(function () {
    activarMenu("Inventario");

    // Cargar tiendas en los combos
    cargarTiendas();

    // Inicializar tabla de detalle
    actualizarTablaDetalle();

    // Validacion del formulario
    $("#formMovimiento").validate({
        rules: {
            IdTienda: { required: true, min: 1 },
            TipoMovimiento: "required",
            IdProducto: { required: true, min: 1 },
            Cantidad: { required: true, min: 1 },
            Motivo: "required"
        },
        messages: {
            IdTienda: "(*)",
            TipoMovimiento: "(*)",
            IdProducto: "(*)",
            Cantidad: "(*)",
            Motivo: "(*)"
        },
        errorElement: 'span'
    });

    // Inicializar tabla de movimientos
    tablaMovimientos = $('#tbMovimientos').DataTable({
        "ajax": {
            "url": $.MisUrls.url._ObtenerMovimientosAgrupados + "?idTienda=0",
            "type": "GET",
            "datatype": "json"
        },
        "columns": [
            {
                "data": "FechaRegistro", "render": function (data) {
                    if (!data) return '';
                    
                    // Parsear fecha en formato compatible
                    var fecha = data.replace('/Date(', '').replace(')/', '');
                    var date = new Date(parseInt(fecha));
                    
                    if (isNaN(date.getTime())) {
                        // Intentar con otro formato
                        date = new Date(data);
                    }
                    
                    if (isNaN(date.getTime())) {
                        return 'Fecha invalida';
                    }
                    
                    var dia = ("0" + date.getDate()).slice(-2);
                    var mes = ("0" + (date.getMonth() + 1)).slice(-2);
                    var anio = date.getFullYear();
                    var hora = ("0" + date.getHours()).slice(-2);
                    var min = ("0" + date.getMinutes()).slice(-2);
                    
                    return dia + '/' + mes + '/' + anio + ' ' + hora + ':' + min;
                }
            },
            { "data": "oTienda.Nombre" },
            { "data": "ProductosResumen" },
            { 
                "data": "CantidadProductos", "render": function (data) {
                    return data + ' producto(s)';
                }
            },
            {
                "data": "TipoMovimiento", "render": function (data) {
                    if (data === "Ingreso") {
                        return '<span class="badge badge-success"><i class="fa fa-arrow-up"></i> Ingreso</span>';
                    } else {
                        return '<span class="badge badge-danger"><i class="fa fa-arrow-down"></i> Egreso</span>';
                    }
                }
            },
            { "data": "Motivo" },
            { "data": "oUsuario.Nombres" },
            {
                "data": "IdLote", 
                "defaultContent": "",
                "render": function (data, type, row) {
                    if (data && data !== null && data.trim() !== '') {
                        return '<button class="btn btn-info btn-sm" onclick="verDetalleLote(\'' + data + '\')"><i class="fa fa-eye"></i> Ver Detalle</button>';
                    }
                    return '<span class="text-muted">-</span>';
                },
                "orderable": false,
                "searchable": false
            }
        ],
        "language": {
            "url": $.MisUrls.url.Url_datatable_spanish
        },
        "order": [[0, "desc"]],
        responsive: true
    });

    // Inicializar tabla de productos (modal) - se carga cuando se abre el modal
    tablaProductos = $('#tbProductos').DataTable({
        "columns": [
            { "data": "Codigo" },
            { "data": "Nombre" },
            { "data": "oCategoria.Descripcion" },
            {
                "data": "IdProducto", "render": function (data, type, row, meta) {
                    return "<button class='btn btn-primary btn-sm' type='button' onclick='seleccionarProducto(" + JSON.stringify(row) + ")'><i class='fa fa-check'></i> Seleccionar</button>";
                },
                "orderable": false,
                "searchable": false,
                "width": "100px"
            }
        ],
        "language": {
            "url": $.MisUrls.url.Url_datatable_spanish
        },
        responsive: true
    });
});

function cargarTiendas() {
    jQuery.ajax({
        url: $.MisUrls.url._ObtenerTiendas,
        type: "GET",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            $("#cboTienda").html("");
            $("#cboFiltroTienda").html("");

            $("#cboTienda").append('<option value="0">-- Seleccione Tienda --</option>');
            $("#cboFiltroTienda").append('<option value="0">-- Todas las Tiendas --</option>');

            $.each(data.data, function (i, item) {
                if (item.Activo) {
                    $("#cboTienda").append('<option value="' + item.IdTienda + '">' + item.Nombre + '</option>');
                    $("#cboFiltroTienda").append('<option value="' + item.IdTienda + '">' + item.Nombre + '</option>');
                }
            });
        },
        error: function (error) {
            console.log(error);
            swal("Error", "No se pudieron cargar las tiendas", "error");
        }
    });
}

$('#btnBuscarProducto').on('click', function () {
    if ($("#cboTienda").val() == "0") {
        swal("Mensaje", "Debe seleccionar una tienda primero", "warning");
        return;
    }
    cargarProductos();
    $('#modalProducto').modal('show');
});

function cargarProductos() {
    var idTienda = parseInt($("#cboTienda").val());
    
    if (idTienda == 0) {
        swal("Mensaje", "Debe seleccionar una tienda primero", "warning");
        return;
    }
    
    jQuery.ajax({
        url: $.MisUrls.url._ObtenerProductosPorTienda + "?idTienda=" + idTienda,
        type: "GET",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            tablaProductos.clear();
            if (data.data && data.data.length > 0) {
                tablaProductos.rows.add(data.data).draw();
            } else {
                swal("Informacion", "No hay productos asignados a esta tienda", "info");
            }
        },
        error: function (error) {
            console.log(error);
            swal("Error", "No se pudieron cargar los productos", "error");
        }
    });
}

function seleccionarProducto(producto) {
    productoSeleccionado = producto;
    $("#txtIdProducto").val(producto.IdProducto);
    $("#txtProducto").val(producto.Codigo + " - " + producto.Nombre);
    $('#modalProducto').modal('hide');
}

// Agregar producto al carrito
$('#btnAgregarProducto').on('click', function () {
    var idTienda = parseInt($("#cboTienda").val());
    var idProducto = parseInt($("#txtIdProducto").val());
    var tipoMovimiento = $("#cboTipoMovimiento").val();
    var cantidad = parseInt($("#txtCantidad").val());

    // Validaciones
    if (idTienda == 0) {
        swal("Mensaje", "Debe seleccionar una tienda", "warning");
        return;
    }
    if (!tipoMovimiento) {
        swal("Mensaje", "Debe seleccionar un tipo de movimiento", "warning");
        return;
    }
    if (idProducto == 0) {
        swal("Mensaje", "Debe seleccionar un producto", "warning");
        return;
    }
    if (cantidad <= 0) {
        swal("Mensaje", "La cantidad debe ser mayor a cero", "warning");
        return;
    }

    // Verificar si el producto ya esta en la lista
    var existe = detalleMovimiento.find(x => x.IdProducto === idProducto);
    if (existe) {
        swal("Mensaje", "Este producto ya esta en la lista", "warning");
        return;
    }

    // Agregar al array (sin motivo individual)
    detalleMovimiento.push({
        IdProducto: idProducto,
        Codigo: productoSeleccionado.Codigo,
        Nombre: productoSeleccionado.Nombre,
        Cantidad: cantidad
    });

    // Actualizar tabla
    actualizarTablaDetalle();

    // Limpiar solo campos de producto
    $("#txtIdProducto").val("0");
    $("#txtProducto").val("");
    $("#txtCantidad").val("1");
    productoSeleccionado = null;
});

function actualizarTablaDetalle() {
    $("#tbDetalleMovimiento tbody").html("");
    
    if (detalleMovimiento.length === 0) {
        $("#tbDetalleMovimiento tbody").append(
            '<tr><td colspan="4" class="text-center">No hay productos agregados</td></tr>'
        );
        return;
    }

    detalleMovimiento.forEach(function (item, index) {
        var fila = '<tr>' +
            '<td>' + item.Nombre + '</td>' +
            '<td>' + item.Codigo + '</td>' +
            '<td>' + item.Cantidad + '</td>' +
            '<td><button class="btn btn-danger btn-sm" onclick="eliminarProducto(' + index + ')"><i class="fa fa-trash"></i></button></td>' +
            '</tr>';
        $("#tbDetalleMovimiento tbody").append(fila);
    });
}

function eliminarProducto(index) {
    detalleMovimiento.splice(index, 1);
    actualizarTablaDetalle();
}

$('#btnGuardarMovimiento').on('click', function () {
    guardarMovimiento();
});

function guardarMovimiento() {
    var idTienda = parseInt($("#cboTienda").val());
    var tipoMovimiento = $("#cboTipoMovimiento").val();
    var motivo = $("#txtMotivo").val();

    // Validaciones
    if (idTienda == 0) {
        swal("Mensaje", "Debe seleccionar una tienda", "warning");
        return;
    }

    if (!tipoMovimiento) {
        swal("Mensaje", "Debe seleccionar un tipo de movimiento", "warning");
        return;
    }

    if (!motivo || motivo.trim() === "") {
        swal("Mensaje", "Debe ingresar un motivo", "warning");
        return;
    }

    if (detalleMovimiento.length === 0) {
        swal("Mensaje", "Debe agregar al menos un producto", "warning");
        return;
    }

    // Guardar todos los movimientos
    swal({
        title: "Esta seguro?",
        text: "Se registraran " + detalleMovimiento.length + " movimientos de stock",
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#28a745",
        confirmButtonText: "Si, registrar",
        cancelButtonText: "Cancelar",
        closeOnConfirm: false
    }, function (isConfirm) {
        if (isConfirm) {
            guardarMovimientos(idTienda, tipoMovimiento, motivo);
        }
    });
}

function guardarMovimientos(idTienda, tipoMovimiento, motivo) {
    console.log("Iniciando guardado de movimientos...");
    console.log("IdTienda:", idTienda);
    console.log("TipoMovimiento:", tipoMovimiento);
    console.log("Total productos:", detalleMovimiento.length);
    
    // Generar IdLote unico para este grupo de movimientos
    var idLote = "LOTE_" + Date.now();
    console.log("IdLote generado:", idLote);
    
    var movimientosGuardados = 0;
    var movimientosError = 0;
    var totalMovimientos = detalleMovimiento.length;

    detalleMovimiento.forEach(function (item, index) {
        console.log("Procesando producto:", item.Nombre);
        var request = {
            objeto: {
                oTienda: { IdTienda: idTienda },
                oProducto: { IdProducto: item.IdProducto },
                TipoMovimiento: tipoMovimiento,
                Cantidad: item.Cantidad,
                Motivo: motivo,
                IdLote: idLote
            }
        };

        jQuery.ajax({
            url: $.MisUrls.url._GuardarMovimiento,
            type: "POST",
            data: JSON.stringify(request),
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                console.log("Respuesta del servidor:", data);
                if (data.resultado) {
                    movimientosGuardados++;
                    console.log("Movimiento guardado exitosamente");
                } else {
                    movimientosError++;
                    console.log("Error al guardar movimiento:", data.mensaje);
                }

                // Si es el ultimo movimiento, mostrar resultado
                if ((movimientosGuardados + movimientosError) === totalMovimientos) {
                    if (movimientosError === 0) {
                        swal("Exito", "Se registraron " + movimientosGuardados + " movimientos correctamente", "success");
                    } else {
                        swal("Advertencia", "Se registraron " + movimientosGuardados + " movimientos. " + movimientosError + " fallaron", "warning");
                    }
                    tablaMovimientos.ajax.reload();
                    limpiarFormulario();
                }
            },
            error: function (error) {
                movimientosError++;
                console.log("Error AJAX:", error);
                console.log("Status:", error.status);
                console.log("Response:", error.responseText);

                // Si es el ultimo movimiento, mostrar resultado
                if ((movimientosGuardados + movimientosError) === totalMovimientos) {
                    swal("Error", "Se registraron " + movimientosGuardados + " movimientos. " + movimientosError + " fallaron", "error");
                    tablaMovimientos.ajax.reload();
                    limpiarFormulario();
                }
            }
        });
    });
}

$('#btnLimpiar').on('click', function () {
    limpiarFormulario();
});

function limpiarFormulario() {
    $("#cboTienda").val("0");
    $("#cboTipoMovimiento").val("");
    $("#txtIdProducto").val("0");
    $("#txtProducto").val("");
    $("#txtCantidad").val("1");
    $("#txtMotivo").val("");
    productoSeleccionado = null;
    detalleMovimiento = [];
    actualizarTablaDetalle();
    $("#formMovimiento").validate().resetForm();
}

$('#btnFiltrar').on('click', function () {
    var idTienda = parseInt($("#cboFiltroTienda").val());
    tablaMovimientos.ajax.url($.MisUrls.url._ObtenerMovimientosAgrupados + "?idTienda=" + idTienda).load();
});

// Funcion para ver detalle del lote de movimientos
function verDetalleLote(idLote) {
    console.log("Ver detalle del lote:", idLote);
    
    jQuery.ajax({
        url: $.MisUrls.url._ObtenerMovimientos + "?idTienda=0",
        type: "GET",
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (response) {
            // Filtrar movimientos por IdLote
            var movimientosLote = response.data.filter(m => m.IdLote === idLote);
            
            if (movimientosLote.length > 0) {
                var primerMovimiento = movimientosLote[0];
                
                // Llenar informacion general
                var fechaData = primerMovimiento.FechaRegistro;
                var fechaStr = fechaData.replace('/Date(', '').replace(')/', '');
                var fecha = new Date(parseInt(fechaStr));
                
                if (isNaN(fecha.getTime())) {
                    fecha = new Date(fechaData);
                }
                
                var dia = ("0" + fecha.getDate()).slice(-2);
                var mes = ("0" + (fecha.getMonth() + 1)).slice(-2);
                var anio = fecha.getFullYear();
                var hora = ("0" + fecha.getHours()).slice(-2);
                var min = ("0" + fecha.getMinutes()).slice(-2);
                
                $("#detalleFecha").text(dia + '/' + mes + '/' + anio + ' ' + hora + ':' + min);
                $("#detalleUsuario").text(primerMovimiento.oUsuario.Nombres);
                $("#detalleMotivo").text(primerMovimiento.Motivo);
                
                // Llenar tabla de productos
                $("#tbDetalleProductos tbody").html("");
                movimientosLote.forEach(function (mov) {
                    var fila = '<tr>' +
                        '<td>' + mov.oProducto.Nombre + '</td>' +
                        '<td>' + mov.oProducto.Codigo + '</td>' +
                        '<td>' + mov.Cantidad + '</td>' +
                        '</tr>';
                    $("#tbDetalleProductos tbody").append(fila);
                });
                
                // Mostrar modal
                $('#modalDetalleLote').modal('show');
            } else {
                swal("Error", "No se encontraron movimientos para este lote", "error");
            }
        },
        error: function (error) {
            console.log(error);
            swal("Error", "No se pudo obtener el detalle del movimiento", "error");
        }
    });
}
