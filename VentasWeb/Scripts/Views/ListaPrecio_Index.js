var tabladata;

$(document).ready(function () {
    activarMenu("Administracion");
    cargarTiendas();
    inicializarTabla();
    
    // Manejar checkbox de copiar desde otra lista
    $('#chkCopiarDesde').on('change', function() {
        if ($(this).is(':checked')) {
            $('#seccionCopiarPrecios').slideDown();
            cargarListasOrigen();
        } else {
            $('#seccionCopiarPrecios').slideUp();
            $('#cboListaOrigen').val('0');
            $('#txtPorcentajeAjuste').val('0');
        }
    });
});

function inicializarTabla() {
    tabladata = $('#tbListasPrecios').DataTable({
        "ajax": {
            "url": "/ListaPrecio/ObtenerListasPrecios",
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
            { "data": "Nombre" },
            { "data": "TipoLista" },
            { 
                "data": "Descripcion",
                "render": function (data) {
                    return data || '<span class="text-muted">Sin descripcion</span>';
                }
            },
            { 
                "data": "oTienda",
                "render": function (data) {
                    return data ? data.Nombre : '<span class="text-muted">Todas</span>';
                }
            },
            { 
                "data": "CantidadProductos",
                "render": function (data) {
                    return '<span class="badge badge-info">' + data + '</span>';
                }
            },
            { 
                "data": "ProductosVigentes",
                "render": function (data) {
                    return '<span class="badge badge-success">' + data + '</span>';
                }
            },
            {
                "data": "Activo",
                "render": function (data) {
                    if (data) {
                        return '<span class="badge badge-success">Activo</span>';
                    } else {
                        return '<span class="badge badge-danger">Inactivo</span>';
                    }
                }
            },
            {
                "data": null,
                "render": function (data, type, row) {
                    return `
                        <button class='btn btn-primary btn-sm' title='Ver Productos' onclick='verDetalle(${row.IdListaPrecio})'>
                            <i class='fa fa-list'></i>
                        </button>
                        <button class='btn btn-warning btn-sm' title='Editar' onclick='editarLista(${JSON.stringify(row)})'>
                            <i class='fa fa-edit'></i>
                        </button>
                        <button class='btn btn-danger btn-sm' title='Eliminar' onclick='eliminarLista(${row.IdListaPrecio}, "${row.Nombre}")'>
                            <i class='fa fa-trash'></i>
                        </button>
                    `;
                },
                "orderable": false,
                "searchable": false,
                "width": "160px"
            }
        ],
        "language": {
            "url": "//cdn.datatables.net/plug-ins/1.10.24/i18n/Spanish.json"
        },
        responsive: true,
        order: [[0, 'asc']]
    });
}

function cargarTiendas() {
    $.ajax({
        url: "/Tienda/Obtener",
        type: "GET",
        dataType: "json",
        success: function (data) {
            var select = $("#cboTienda");
            select.empty();
            select.append('<option value="">-- Todas las tiendas --</option>');
            
            if (data.data) {
                $.each(data.data, function (i, item) {
                    select.append($('<option>', {
                        value: item.IdTienda,
                        text: item.Nombre
                    }));
                });
            }
        },
        error: function (error) {
            console.log("Error al cargar tiendas:", error);
        }
    });
}

function abrirModalNuevaLista() {
    $("#formListaPrecio")[0].reset();
    $("#txtIdListaPrecio").val("0");
    $("#modalTitulo").text("Nueva Lista de Precios");
    $("#cboActivo").val("true");
    
    // Resetear sección de copiar
    $('#chkCopiarDesde').prop('checked', false);
    $('#seccionCopiarPrecios').hide();
    $('#cboListaOrigen').val('0');
    $('#txtPorcentajeAjuste').val('0');
    
    $("#modalListaPrecio").modal("show");
}

function editarLista(data) {
    $("#txtIdListaPrecio").val(data.IdListaPrecio);
    $("#txtNombre").val(data.Nombre);
    $("#txtDescripcion").val(data.Descripcion);
    $("#cboTipoLista").val(data.TipoLista);
    $("#cboTienda").val(data.IdTienda || "");
    $("#cboActivo").val(data.Activo.toString());
    
    // Ocultar opción de copiar al editar
    $('#chkCopiarDesde').prop('checked', false).prop('disabled', true);
    $('#seccionCopiarPrecios').hide();
    
    $("#modalTitulo").text("Editar Lista de Precios");
    $("#modalListaPrecio").modal("show");
    
    // Re-habilitar al cerrar
    $('#modalListaPrecio').on('hidden.bs.modal', function () {
        $('#chkCopiarDesde').prop('disabled', false);
    });
}

function guardarListaPrecio() {
    var idLista = parseInt($("#txtIdListaPrecio").val());
    var nombre = $("#txtNombre").val().trim();
    var tipoLista = $("#cboTipoLista").val();
    
    // Validaciones
    if (!nombre) {
        swal("Atencion", "Ingrese el nombre de la lista", "warning");
        return;
    }
    
    if (!tipoLista) {
        swal("Atencion", "Seleccione el tipo de lista", "warning");
        return;
    }
    
    // Validar que no exista otra lista con el mismo nombre y tipo (solo al crear)
    if (idLista === 0) {
        var existeDuplicado = false;
        var datosTabla = tabladata.data();
        
        for (var i = 0; i < datosTabla.length; i++) {
            if (datosTabla[i].Nombre.toLowerCase() === nombre.toLowerCase() && 
                datosTabla[i].TipoLista === tipoLista) {
                existeDuplicado = true;
                break;
            }
        }
        
        if (existeDuplicado) {
            swal("Atencion", "Ya existe una lista con el nombre '" + nombre + "' y tipo '" + tipoLista + "'", "warning");
            return;
        }
    }
    
    var idTienda = $("#cboTienda").val();
    
    var objeto = {
        IdListaPrecio: idLista,
        Nombre: nombre,
        Descripcion: $("#txtDescripcion").val().trim(),
        TipoLista: tipoLista,
        IdTienda: idTienda ? parseInt(idTienda) : null,
        Activo: $("#cboActivo").val() === "true"
    };
    
    // Si está marcado copiar desde otra lista
    if (idLista === 0 && $('#chkCopiarDesde').is(':checked')) {
        var idListaOrigen = parseInt($('#cboListaOrigen').val());
        var porcentajeAjuste = parseFloat($('#txtPorcentajeAjuste').val());
        
        if (idListaOrigen === 0) {
            swal("Atencion", "Seleccione la lista de origen", "warning");
            return;
        }
        
        objeto.IdListaOrigen = idListaOrigen;
        objeto.PorcentajeAjuste = porcentajeAjuste;
        
        // Usar endpoint especial para copiar
        copiarListaConAjuste(objeto);
        return;
    }
    
    var url = idLista === 0 ? "/ListaPrecio/RegistrarListaPrecio" : "/ListaPrecio/ModificarListaPrecio";
    
    $.ajax({
        url: url,
        type: "POST",
        data: JSON.stringify(objeto),
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.success) {
                swal("Exito", data.mensaje, "success");
                $("#modalListaPrecio").modal("hide");
                tabladata.ajax.reload();
            } else {
                swal("Error", data.mensaje, "error");
            }
        },
        error: function (error) {
            console.log(error);
            swal("Error", "Ocurrio un error al procesar la solicitud", "error");
        }
    });
}

function cargarListasOrigen() {
    $.ajax({
        url: "/ListaPrecio/ObtenerListasPrecios",
        type: "GET",
        dataType: "json",
        success: function (data) {
            var select = $("#cboListaOrigen");
            select.empty();
            select.append('<option value="0">-- Seleccione una lista --</option>');
            
            if (data.success && data.data) {
                $.each(data.data, function (i, item) {
                    if (item.Activo && item.CantidadProductos > 0) {
                        select.append($('<option>', {
                            value: item.IdListaPrecio,
                            text: item.Nombre + ' (' + item.CantidadProductos + ' productos)'
                        }));
                    }
                });
            }
        },
        error: function (error) {
            console.log("Error al cargar listas:", error);
        }
    });
}

function copiarListaConAjuste(objeto) {
    swal({
        title: "Confirmacion",
        text: "Desea crear la lista '" + objeto.Nombre + "' copiando precios con un ajuste del " + objeto.PorcentajeAjuste + "%?",
        type: "info",
        showCancelButton: true,
        confirmButtonText: "Si, crear",
        cancelButtonText: "Cancelar"
    }, function(isConfirm) {
        if (isConfirm) {
            // Preparar datos para model binding
            var datos = {
                'lista.Nombre': objeto.Nombre,
                'lista.Descripcion': objeto.Descripcion || '',
                'lista.TipoLista': objeto.TipoLista,
                'lista.Activo': objeto.Activo,
                'IdListaOrigen': objeto.IdListaOrigen,
                'PorcentajeAjuste': objeto.PorcentajeAjuste
            };
            
            // Solo agregar IdTienda si tiene valor
            if (objeto.IdTienda) {
                datos['lista.IdTienda'] = objeto.IdTienda;
            }
            
            $.ajax({
                url: "/ListaPrecio/CopiarListaConAjuste",
                type: "POST",
                data: datos,
                beforeSend: function() {
                    swal({
                        title: "Procesando...",
                        text: "Copiando productos y ajustando precios",
                        imageUrl: "/Content/images/loading.gif",
                        showConfirmButton: false,
                        allowOutsideClick: false
                    });
                },
                success: function (data) {
                    if (data.success) {
                        var mensaje = data.mensaje;
                        
                        // Si hay errores, mostrar advertencia en lugar de exito
                        if (data.productosErrores > 0) {
                            mensaje += "\n\nAlgunos productos no se pudieron copiar.";
                            swal({
                                title: "Advertencia",
                                text: mensaje,
                                type: "warning"
                            });
                        } else {
                            swal({
                                title: "Exito!",
                                text: mensaje,
                                type: "success"
                            });
                        }
                        
                        $("#modalListaPrecio").modal("hide");
                        tabladata.ajax.reload();
                    } else {
                        var mensajeError = data.mensaje;
                        
                        // Si hay lista de errores, mostrarlos
                        if (data.errores && data.errores.length > 0) {
                            mensajeError += "\n\nErrores:\n" + data.errores.slice(0, 5).join("\n");
                            if (data.errores.length > 5) {
                                mensajeError += "\n... y " + (data.errores.length - 5) + " errores mas";
                            }
                        }
                        
                        swal("Error", mensajeError, "error");
                    }
                },
                error: function (error) {
                    console.log(error);
                    swal("Error", "Ocurrio un error al copiar la lista", "error");
                }
            });
        }
    });
}

function verDetalle(idListaPrecio) {
    window.location.href = "/ListaPrecio/Detalle/" + idListaPrecio;
}

function eliminarLista(idListaPrecio, nombreLista) {
    swal({
        title: "Eliminar Lista de Precios",
        text: "Esta seguro de eliminar la lista '" + nombreLista + "'? Esta accion no se puede deshacer.",
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#d33",
        confirmButtonText: "Si, eliminar",
        cancelButtonText: "Cancelar"
    }, function(isConfirm) {
        if (isConfirm) {
            $.ajax({
                url: "/ListaPrecio/EliminarListaPrecio",
                type: "POST",
                data: JSON.stringify({ IdListaPrecio: idListaPrecio }),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                beforeSend: function() {
                    swal({
                        title: "Eliminando...",
                        text: "Por favor espere",
                        imageUrl: "/Content/images/loading.gif",
                        showConfirmButton: false,
                        allowOutsideClick: false
                    });
                },
                success: function (data) {
                    if (data.success) {
                        swal("Eliminado", data.mensaje, "success");
                        tabladata.ajax.reload();
                    } else {
                        swal("Error", data.mensaje, "error");
                    }
                },
                error: function (error) {
                    console.log(error);
                    swal("Error", "Ocurrio un error al eliminar la lista", "error");
                }
            });
        }
    });
}
