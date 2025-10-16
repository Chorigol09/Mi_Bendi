/* REEMPLAZO COMPLETO: Scripts/Views/Reporte_Producto.js */
console.log("Reporte_Producto.js v8 cargado");

(function () {

    // -------- helpers numericos --------
    function toNumberLoose(v) {
        if (v == null) return 0;
        if (typeof v === 'number') return v;
        var s = String(v).trim();
        if (!s) return 0;
        var en = s.replace(/[^\d.\-]/g, '');
        var nEn = parseFloat(en);
        if (!isNaN(nEn)) return nEn;
        var es = s.replace(/[^\d,\-]/g, '').replace(/\./g, '').replace(',', '.');
        var nEs = parseFloat(es);
        return isNaN(nEs) ? 0 : nEs;
    }
    function formatMilesSinDec(v) {
        var n = toNumberLoose(v);
        return new Intl.NumberFormat('es-AR', { minimumFractionDigits: 0, maximumFractionDigits: 0 }).format(n);
    }

    // -------- cargar tiendas --------
    $(document).ready(function () {
        if (typeof activarMenu === 'function') activarMenu("Reportes");

        $.ajax({
            url: $.MisUrls.url._ObtenerTiendas,
            type: "GET",
            dataType: "json",
            success: function (data) {
                $("#cboTienda").LoadingOverlay("hide").html("");
                $("<option>").attr({ value: 0 }).text("-- Seleccionar todas--").appendTo("#cboTienda");
                if (data && data.data) {
                    $.each(data.data, function (i, t) {
                        if (t.Activo === true) $("<option>").val(t.IdTienda).text(t.Nombre).appendTo("#cboTienda");
                    });
                }
            },
            error: function (e) { console.log(e); },
            beforeSend: function () { $("#cboTienda").LoadingOverlay("show"); }
        });
    });

    // -------- buscar productos --------
    $('#btnBuscar').on('click', function () {
        var idTienda = $("#cboTienda").val();
        var codigo = $("#txtCodigoProducto").val();

        $.ajax({
            url: $.MisUrls.url._ObtenerReporteProducto + "?idtienda=" + encodeURIComponent(idTienda) + "&codigoproducto=" + encodeURIComponent(codigo),
            type: "GET",
            dataType: "json",
            success: function (data) {
                var $tb = $("#tbReporte tbody").empty();
                if (!data) return;

                data.forEach(function (r) {
                    var stock = Number(r.StockenTienda) || 0;
                    var idProd = r.IdProducto;
                    var idProdTienda = r.IdProductoTienda;
                    var idTnd = r.IdTienda;
                    var pv = r.PrecioVenta || 0;
                    var precioDisplay = pv > 0 ? 'S./ ' + pv.toFixed(2) : '<span class="text-muted">Sin precio</span>';

                    var downDisabled = stock <= 0 ? "disabled" : "";

                    // Escapar comillas para JSON
                    var rowData = {
                        IdProductoTienda: idProdTienda,
                        NombreProducto: r.NombreProducto || '',
                        NombreTienda: r.NombreTienda || '',
                        PrecioVenta: pv
                    };

                    var html =
                        '<tr>' +
                        '<td>' + (r.RucTienda || '') + '</td>' +
                        '<td>' + (r.NombreTienda || '') + '</td>' +
                        '<td>' + (r.DireccionTienda || '') + '</td>' +
                        '<td>' + (r.CodigoProducto || '') + '</td>' +
                        '<td>' + (r.NombreProducto || '') + '</td>' +
                        '<td>' + (r.DescripcionProducto || '') + '</td>' +
                        '<td class="col-stock" data-idproducto="' + idProd + '" data-idtienda="' + idTnd + '">' + stock + '</td>' +

                        // --- Precio Venta (readonly) ---
                        '<td>' + precioDisplay + '</td>' +

                        // --- Boton Modificar Precio ---
                        '<td>' +
                        '<button class="btn btn-warning btn-sm btn-modificar-precio" ' +
                        'data-row=\'' + JSON.stringify(rowData).replace(/'/g, "&apos;") + '\' ' +
                        'title="Modificar Precio">' +
                        '<i class="fas fa-edit"></i> Modificar' +
                        '</button>' +
                        '</td>' +

                        // --- Editar Stock (flechas) ---
                        '<td>' +
                        '<div class="btn-group btn-group-sm" role="group">' +
                        '<button class="btn btn-outline-success btn-stock-up"  data-idproducto="' + idProd + '" data-idtienda="' + idTnd + '" title="Sumar 1"><i class="fas fa-arrow-up"></i></button>' +
                        '<button class="btn btn-outline-danger  btn-stock-down" data-idproducto="' + idProd + '" data-idtienda="' + idTnd + '" ' + downDisabled + ' title="Restar 1"><i class="fas fa-arrow-down"></i></button>' +
                        '</div>' +
                        '</td>' +
                        '</tr>';

                    $tb.append(html);
                });
            },
            error: function (e) { console.log("Error reporte:", e); }
        });
    });

    // -------- Abrir modal para modificar precio --------
    $('#tbReporte').on('click', '.btn-modificar-precio', function () {
        var rowData = JSON.parse($(this).attr('data-row').replace(/&apos;/g, "'"));
        
        $("#txtIdProductoTiendaModal").val(rowData.IdProductoTienda);
        $("#txtProductoNombreModal").val(rowData.NombreProducto);
        $("#txtTiendaNombreModal").val(rowData.NombreTienda);
        $("#txtNuevoPrecioVentaModal").val(rowData.PrecioVenta || '');
        
        $('#modalPrecioVenta').modal('show');
    });

    // -------- Guardar precio desde el modal --------
    $('#btnGuardarPrecioModal').on('click', function () {
        var idProductoTienda = $("#txtIdProductoTiendaModal").val();
        var nuevoPrecio = $("#txtNuevoPrecioVentaModal").val();

        if (!nuevoPrecio || parseFloat(nuevoPrecio) < 0) {
            swal("Mensaje", "Por favor ingrese un precio valido", "warning");
            return;
        }

        var request = {
            idProductoTienda: parseInt(idProductoTienda),
            precioVenta: parseFloat(nuevoPrecio)
        };

        $.ajax({
            url: $.MisUrls.url._ActualizarPrecioVentaTienda,
            type: "POST",
            data: JSON.stringify(request),
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                if (data.resultado) {
                    swal("Exito", "Precio de venta actualizado correctamente", "success");
                    $('#modalPrecioVenta').modal('hide');
                    // Recargar la busqueda
                    $('#btnBuscar').click();
                } else {
                    swal("Error", data.mensaje || "No se pudo actualizar el precio de venta", "error");
                }
            },
            error: function (error) {
                console.log(error);
                swal("Error", "Error al actualizar el precio", "error");
            }
        });
    });

    // -------- editar stock (↑ ↓) --------
    function postAjuste(idProducto, idTienda, delta) {
        return $.ajax({
            url: $.MisUrls.url._AjustarStock,
            type: "POST",
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({ idProducto: idProducto, idTienda: idTienda, delta: delta })
        });
    }

    // actualiza la celda visualmente y luego llama al servidor; si falla, revierte
    $('#tbReporte').on('click', '.btn-stock-up, .btn-stock-down', function () {
        var $btn = $(this);
        var idP = $btn.data('idproducto');
        var idT = $btn.data('idtienda');
        var delta = $btn.hasClass('btn-stock-up') ? +1 : -1;

        var $tr = $btn.closest('tr');
        var $stockCell = $tr.find('.col-stock');
        var actual = toNumberLoose($stockCell.text());
        var nuevo = actual + delta;
        if (nuevo < 0) return; // no bajo de 0

        // optimista
        $stockCell.text(nuevo);

        postAjuste(idP, idT, delta).done(function (response) {
            if (response.ok) {
                // si quedo en 0, deshabilitar down
                var $down = $tr.find('.btn-stock-down');
                if (nuevo <= 0) $down.prop('disabled', true);
                else $down.prop('disabled', false);
            } else {
                // revertir
                $stockCell.text(actual);
                alert(response.mensaje || "No se pudo ajustar el stock");
            }
        }).fail(function (xhr) {
            // revertir
            $stockCell.text(actual);
            alert("Error al ajustar stock: " + (xhr.responseText || "Error desconocido"));
        });
    });

})();
