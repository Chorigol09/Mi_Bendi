/* REEMPLAZO COMPLETO: Scripts/Views/Reporte_Producto.js */
console.log("Reporte_Producto.js v10 cargado - Sin columna Editar Stock");

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
                    var precioDisplay;
                    if (pv > 0) {
                        // Formatear como $X.XXX,XX (punto para miles, coma para decimales)
                        var numero = pv.toFixed(2);
                        var partes = numero.split('.');
                        var entero = partes[0].replace(/\B(?=(\d{3})+(?!\d))/g, ".");
                        var decimal = partes[1];
                        precioDisplay = "$" + entero + "," + decimal;
                    } else {
                        precioDisplay = '<span class="text-muted">Sin precio</span>';
                    }

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

})();
