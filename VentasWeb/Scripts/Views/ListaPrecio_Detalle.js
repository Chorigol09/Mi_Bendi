var tabladata;
var infoListaPrecio = null;
var filtroActual = 'todos';

$(document).ready(function () {
    activarMenu("Administracion");
    cargarInformacionLista();
    inicializarTabla();
    
    // Establecer fecha por defecto en los campos de fecha
    var hoy = new Date().toISOString().split('T')[0];
    $("#txtFechaDesdeAdd").val(hoy);
    $("#txtFechaHastaAdd").val(hoy);
});

function cargarInformacionLista() {
    $.ajax({
        url: "/ListaPrecio/ObtenerListasPrecios",
        type: "GET",
        dataType: "json",
        success: function (response) {
            if (response.success) {
                var lista = response.data.find(x => x.IdListaPrecio === idListaPrecio);
                if (lista) {
                    infoListaPrecio = lista;
                    $("#tituloLista").text(lista.Nombre);
                    $("#infoNombreLista").text(lista.Nombre);
                    $("#infoTipoLista").text(lista.TipoLista);
                    $("#infoCantidadProductos").text(lista.CantidadProductos);
                    $("#infoProductosVigentes").text(lista.ProductosVigentes);
                }
            }
        },
        error: function (error) {
            console.log("Error al cargar información:", error);
        }
    });
}

function inicializarTabla() {
    tabladata = $('#tbProductosLista').DataTable({
        "ajax": {
            "url": "/ListaPrecio/ObtenerProductosListaPrecio?idListaPrecio=" + idListaPrecio + "&soloVigentes=false",
            "type": "GET",
            "datatype": "json",
            "dataSrc": function (json) {
                if (json.success) {
                    return json.data;
                }
                return [];
            }
        },
        "columns": [
            { "data": "oProducto.Codigo" },
            { "data": "oProducto.Nombre" },
            { "data": "Categoria" },
            { 
                "data": "PrecioVenta",
                "render": function (data) {
                    return '$' + parseFloat(data).toFixed(2);
                }
            },
            { 
                "data": "FechaVigenciaDesde",
                "render": function (data) {
                    return formatearFecha(data);
                }
            },
            { 
                "data": "FechaVigenciaHasta",
                "render": function (data) {
                    return formatearFecha(data);
                }
            },
            {
                "data": "Activo",
                "render": function (data) {
                    if (data) {
                        return '<span class="badge badge-success">Activo</span>';
                    } else {
                        return '<span class="badge badge-secondary">Inactivo</span>';
                    }
                }
            },
            {
                "data": "EsVigente",
                "render": function (data) {
                    if (data) {
                        return '<span class="badge badge-success"><i class="fa fa-check"></i> Vigente</span>';
                    } else {
                        return '<span class="badge badge-warning"><i class="fa fa-clock"></i> No vigente</span>';
                    }
                }
            },
            {
                "data": null,
                "render": function (data, type, row) {
                    return `
                        <button class='btn btn-warning btn-sm' title='Editar' onclick='editarProducto(${JSON.stringify(row)})'>
                            <i class='fa fa-edit'></i>
                        </button>
                        <button class='btn btn-danger btn-sm' title='Eliminar' onclick='eliminarProducto(${row.IdListaPrecioDetalle})'>
                            <i class='fa fa-trash'></i>
                        </button>
                    `;
                },
                "orderable": false,
                "searchable": false,
                "width": "100px"
            }
        ],
        "language": {
            "url": "//cdn.datatables.net/plug-ins/1.10.24/i18n/Spanish.json"
        },
        responsive: true,
        order: [[1, 'asc']]
    });
}

function formatearFecha(fecha) {
    if (!fecha) return '';
    var d = new Date(fecha);
    var dia = ("0" + d.getDate()).slice(-2);
    var mes = ("0" + (d.getMonth() + 1)).slice(-2);
    var anio = d.getFullYear();
    return dia + "/" + mes + "/" + anio;
}

function formatearFechaInput(fecha) {
    if (!fecha) return '';
    var d = new Date(fecha);
    var dia = ("0" + d.getDate()).slice(-2);
    var mes = ("0" + (d.getMonth() + 1)).slice(-2);
    var anio = d.getFullYear();
    return anio + "-" + mes + "-" + dia;
}

function filtrarProductos(tipo) {
    filtroActual = tipo;
    var soloVigentes = tipo === 'vigentes';
    
    // Actualizar botones
    $(".btn-group button").removeClass("active");
    if (tipo === 'todos') {
        $(".btn-group button:first").addClass("active");
    } else {
        $(".btn-group button:last").addClass("active");
    }
    
    tabladata.ajax.url("/ListaPrecio/ObtenerProductosListaPrecio?idListaPrecio=" + idListaPrecio + "&soloVigentes=" + soloVigentes).load();
}

function abrirModalAgregarProducto() {
    $("#formAgregarProducto")[0].reset();
    $("#txtIdListaPrecioAdd").val(idListaPrecio);
    
    var hoy = new Date().toISOString().split('T')[0];
    $("#txtFechaDesdeAdd").val(hoy);
    $("#txtFechaHastaAdd").val(hoy);
    
    cargarProductosDisponibles();
    $("#modalAgregarProducto").modal("show");
}

function cargarProductosDisponibles() {
    var fechaDesde = $("#txtFechaDesdeAdd").val();
    var fechaHasta = $("#txtFechaHastaAdd").val();
    
    if (!fechaDesde || !fechaHasta) {
        return;
    }
    
    $.ajax({
        url: "/ListaPrecio/ObtenerProductosDisponibles",
        type: "GET",
        data: {
            idListaPrecio: idListaPrecio,
            fechaDesde: fechaDesde,
            fechaHasta: fechaHasta
        },
        dataType: "json",
        success: function (response) {
            var select = $("#cboProductoAdd");
            select.empty();
            select.append('<option value="">-- Seleccione un producto --</option>');
            
            if (response.success && response.data) {
                $.each(response.data, function (i, item) {
                    select.append($('<option>', {
                        value: item.IdProducto,
                        text: item.Codigo + ' - ' + item.Nombre
                    }));
                });
            }
        },
        error: function (error) {
            console.log("Error al cargar productos:", error);
        }
    });
}

// Recargar productos disponibles cuando cambian las fechas
$("#txtFechaDesdeAdd, #txtFechaHastaAdd").on("change", function () {
    cargarProductosDisponibles();
});

function guardarProductoLista() {
    var idProducto = $("#cboProductoAdd").val();
    var precioVenta = parseFloat($("#txtPrecioVentaAdd").val());
    var fechaDesde = $("#txtFechaDesdeAdd").val();
    var fechaHasta = $("#txtFechaHastaAdd").val();
    
    // Validaciones
    if (!idProducto) {
        swal("Atención", "Seleccione un producto", "warning");
        return;
    }
    
    if (!precioVenta || precioVenta <= 0) {
        swal("Atención", "Ingrese un precio válido", "warning");
        return;
    }
    
    if (!fechaDesde || !fechaHasta) {
        swal("Atención", "Ingrese las fechas de vigencia", "warning");
        return;
    }
    
    if (new Date(fechaDesde) > new Date(fechaHasta)) {
        swal("Atención", "La fecha de inicio debe ser menor o igual a la fecha de fin", "warning");
        return;
    }
    
    var objeto = {
        IdListaPrecio: idListaPrecio,
        IdProducto: parseInt(idProducto),
        PrecioVenta: precioVenta,
        FechaVigenciaDesde: fechaDesde,
        FechaVigenciaHasta: fechaHasta
    };
    
    $.ajax({
        url: "/ListaPrecio/AgregarProductoListaPrecio",
        type: "POST",
        data: JSON.stringify(objeto),
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.success) {
                swal("Éxito", data.mensaje, "success");
                $("#modalAgregarProducto").modal("hide");
                tabladata.ajax.reload();
                cargarInformacionLista();
            } else {
                swal("Error", data.mensaje, "error");
            }
        },
        error: function (error) {
            console.log(error);
            swal("Error", "Ocurrió un error al procesar la solicitud", "error");
        }
    });
}

function editarProducto(data) {
    $("#txtIdListaPrecioDetalle").val(data.IdListaPrecioDetalle);
    $("#txtProductoNombre").val(data.oProducto.Nombre);
    $("#txtPrecioVentaEdit").val(data.PrecioVenta);
    $("#txtFechaDesdeEdit").val(formatearFechaInput(data.FechaVigenciaDesde));
    $("#txtFechaHastaEdit").val(formatearFechaInput(data.FechaVigenciaHasta));
    $("#cboActivoEdit").val(data.Activo.toString());
    
    $("#modalEditarProducto").modal("show");
}

function actualizarProductoLista() {
    var idDetalle = parseInt($("#txtIdListaPrecioDetalle").val());
    var precioVenta = parseFloat($("#txtPrecioVentaEdit").val());
    var fechaDesde = $("#txtFechaDesdeEdit").val();
    var fechaHasta = $("#txtFechaHastaEdit").val();
    var activo = $("#cboActivoEdit").val() === "true";
    
    // Validaciones
    if (!precioVenta || precioVenta <= 0) {
        swal("Atención", "Ingrese un precio válido", "warning");
        return;
    }
    
    if (!fechaDesde || !fechaHasta) {
        swal("Atención", "Ingrese las fechas de vigencia", "warning");
        return;
    }
    
    if (new Date(fechaDesde) > new Date(fechaHasta)) {
        swal("Atención", "La fecha de inicio debe ser menor o igual a la fecha de fin", "warning");
        return;
    }
    
    var objeto = {
        IdListaPrecioDetalle: idDetalle,
        PrecioVenta: precioVenta,
        FechaVigenciaDesde: fechaDesde,
        FechaVigenciaHasta: fechaHasta,
        Activo: activo
    };
    
    $.ajax({
        url: "/ListaPrecio/ModificarProductoListaPrecio",
        type: "POST",
        data: JSON.stringify(objeto),
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.success) {
                swal("Éxito", data.mensaje, "success");
                $("#modalEditarProducto").modal("hide");
                tabladata.ajax.reload();
                cargarInformacionLista();
            } else {
                swal("Error", data.mensaje, "error");
            }
        },
        error: function (error) {
            console.log(error);
            swal("Error", "Ocurrió un error al procesar la solicitud", "error");
        }
    });
}

function eliminarProducto(idDetalle) {
    swal({
        title: "Confirmación",
        text: "¿Está seguro de eliminar este producto de la lista?",
        type: "warning",
        showCancelButton: true,
        confirmButtonText: "Sí, eliminar",
        confirmButtonColor: "#DD6B55",
        cancelButtonText: "Cancelar",
        closeOnConfirm: false
    },
    function () {
        $.ajax({
            url: "/ListaPrecio/EliminarProductoListaPrecio",
            type: "POST",
            data: JSON.stringify({ idListaPrecioDetalle: idDetalle }),
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                if (data.success) {
                    swal("Éxito", data.mensaje, "success");
                    tabladata.ajax.reload();
                    cargarInformacionLista();
                } else {
                    swal("Error", data.mensaje, "error");
                }
            },
            error: function (error) {
                console.log(error);
                swal("Error", "Ocurrió un error al procesar la solicitud", "error");
            }
        });
    });
}
