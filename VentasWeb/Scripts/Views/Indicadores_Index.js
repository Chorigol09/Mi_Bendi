// Variables globales para los gráficos
let chartVentasPorTienda, chartVentasPorTipoDoc, chartVentasPorMetodo, chartVentasPorDia;
let chartComprasPorProveedor, chartComprasPorDia;

$(document).ready(function () {
    activarMenu("Reportes");
    
    // Establecer fechas por defecto (último mes)
    var hoy = new Date();
    var hace30Dias = new Date();
    hace30Dias.setDate(hace30Dias.getDate() - 30);
    
    $("#txtFechaInicio").val(formatearFecha(hace30Dias));
    $("#txtFechaFin").val(formatearFecha(hoy));
    
    // Cargar datos iniciales
    cargarTodosLosDatos();
    
    // Evento del botón filtrar
    $("#btnFiltrar").on('click', function() {
        cargarTodosLosDatos();
    });
});

function formatearFecha(fecha) {
    var dia = ("0" + fecha.getDate()).slice(-2);
    var mes = ("0" + (fecha.getMonth() + 1)).slice(-2);
    var anio = fecha.getFullYear();
    return anio + "-" + mes + "-" + dia;
}

function formatearFechaEsp(fecha) {
    var dia = ("0" + fecha.getDate()).slice(-2);
    var mes = ("0" + (fecha.getMonth() + 1)).slice(-2);
    var anio = fecha.getFullYear();
    return dia + "/" + mes + "/" + anio;
}

function formatearPrecio(valor) {
    if (valor == null || valor === '' || valor === undefined) return "$0,00";
    var numero = parseFloat(valor);
    if (isNaN(numero)) return "$0,00";
    numero = numero.toFixed(2);
    var partes = numero.split('.');
    var entero = partes[0].replace(/\B(?=(\d{3})+(?!\d))/g, ".");
    var decimal = partes[1];
    return "$" + entero + "," + decimal;
}

function cargarTodosLosDatos() {
    var fechaInicio = $("#txtFechaInicio").val();
    var fechaFin = $("#txtFechaFin").val();
    
    if (!fechaInicio || !fechaFin) {
        swal("Atención", "Debe seleccionar ambas fechas", "warning");
        return;
    }
    
    // Convertir formato de fecha
    var partesFI = fechaInicio.split('-');
    var fechaInicioEsp = partesFI[2] + "/" + partesFI[1] + "/" + partesFI[0];
    
    var partesFF = fechaFin.split('-');
    var fechaFinEsp = partesFF[2] + "/" + partesFF[1] + "/" + partesFF[0];
    
    // Cargar todos los datos
    cargarResumenGeneral(fechaInicioEsp, fechaFinEsp);
    cargarVentasPorTienda(fechaInicioEsp, fechaFinEsp);
    cargarVentasPorTipoDocumento(fechaInicioEsp, fechaFinEsp);
    cargarVentasPorMetodoPago(fechaInicioEsp, fechaFinEsp);
    cargarVentasPorDia(fechaInicioEsp, fechaFinEsp);
    cargarTopClientes(fechaInicioEsp, fechaFinEsp);
    cargarTopProductos(fechaInicioEsp, fechaFinEsp);
    cargarComprasPorProveedor(fechaInicioEsp, fechaFinEsp);
    cargarComprasPorDia(fechaInicioEsp, fechaFinEsp);
    cargarTopProveedores(fechaInicioEsp, fechaFinEsp);
    cargarTopProductosComprados(fechaInicioEsp, fechaFinEsp);
}

function cargarResumenGeneral(fechaInicio, fechaFin) {
    $.ajax({
        url: '/Indicadores/ObtenerResumenGeneral',
        type: 'POST',
        data: { fechaInicio: fechaInicio, fechaFin: fechaFin },
        dataType: 'json',
        success: function(response) {
            console.log('Resumen General:', response);
            if (response.data) {
                var data = response.data;
                $("#kpiTotalVentas").text(formatearPrecio(data.TotalVentas));
                $("#kpiCantidadVentas").text(data.CantidadVentas || 0);
                $("#kpiTotalCompras").text(formatearPrecio(data.TotalCompras));
                $("#kpiCantidadCompras").text(data.CantidadCompras || 0);
                $("#kpiMargenBruto").text(formatearPrecio(data.MargenBruto));
                $("#kpiUnidadesVendidas").text(data.UnidadesVendidas || 0);
                $("#kpiClientesUnicos").text(data.ClientesUnicos || 0);
                
                var promedioFormateado = formatearPrecio(data.PromedioVenta).replace('$', '');
                $("#kpiPromedioVenta").text(promedioFormateado);
            }
        },
        error: function(error) {
            console.error('Error al cargar resumen general:', error);
            console.error('Detalles:', error.responseText);
        }
    });
}

function cargarVentasPorTienda(fechaInicio, fechaFin) {
    $.ajax({
        url: '/Indicadores/ObtenerVentasPorTienda',
        type: 'POST',
        data: { fechaInicio: fechaInicio, fechaFin: fechaFin },
        dataType: 'json',
        success: function(response) {
            if (response.data && response.data.length > 0) {
                var labels = response.data.map(x => x.Tienda);
                var valores = response.data.map(x => x.TotalVendido);
                
                if (chartVentasPorTienda) chartVentasPorTienda.destroy();
                
                var ctx = document.getElementById('chartVentasPorTienda').getContext('2d');
                chartVentasPorTienda = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Ventas',
                            data: valores,
                            backgroundColor: ['#36a2eb', '#ff6384', '#4bc0c0', '#ff9f40', '#9966ff', '#ffcd56'],
                            borderRadius: 8
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        return formatearPrecio(context.parsed.y);
                                    }
                                }
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    callback: function(value) {
                                        return '$' + value.toLocaleString('es-AR');
                                    }
                                }
                            }
                        }
                    }
                });
            }
        },
        error: function(error) {
            console.error('Error al cargar ventas por tienda:', error);
        }
    });
}

function cargarVentasPorTipoDocumento(fechaInicio, fechaFin) {
    $.ajax({
        url: '/Indicadores/ObtenerVentasPorTipoDocumento',
        type: 'POST',
        data: { fechaInicio: fechaInicio, fechaFin: fechaFin },
        dataType: 'json',
        success: function(response) {
            if (response.data && response.data.length > 0) {
                var labels = response.data.map(x => x.TipoDocumento);
                var valores = response.data.map(x => x.Total);
                
                if (chartVentasPorTipoDoc) chartVentasPorTipoDoc.destroy();
                
                var ctx = document.getElementById('chartVentasPorTipoDoc').getContext('2d');
                chartVentasPorTipoDoc = new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: labels,
                        datasets: [{
                            data: valores,
                            backgroundColor: ['#36a2eb', '#ff6384', '#4bc0c0', '#ff9f40']
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { position: 'bottom' },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        return context.label + ': ' + formatearPrecio(context.parsed);
                                    }
                                }
                            }
                        }
                    }
                });
            }
        },
        error: function(error) {
            console.error('Error al cargar ventas por tipo documento:', error);
        }
    });
}

function cargarVentasPorMetodoPago(fechaInicio, fechaFin) {
    $.ajax({
        url: '/Indicadores/ObtenerVentasPorMetodoPago',
        type: 'POST',
        data: { fechaInicio: fechaInicio, fechaFin: fechaFin },
        dataType: 'json',
        success: function(response) {
            if (response.data && response.data.length > 0) {
                var labels = response.data.map(x => x.MetodoPago);
                var valores = response.data.map(x => x.Total);
                
                if (chartVentasPorMetodo) chartVentasPorMetodo.destroy();
                
                var ctx = document.getElementById('chartVentasPorMetodo').getContext('2d');
                chartVentasPorMetodo = new Chart(ctx, {
                    type: 'pie',
                    data: {
                        labels: labels,
                        datasets: [{
                            data: valores,
                            backgroundColor: ['#36a2eb', '#ff6384', '#4bc0c0', '#ff9f40', '#9966ff', '#ffcd56']
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { position: 'bottom' },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        return context.label + ': ' + formatearPrecio(context.parsed);
                                    }
                                }
                            }
                        }
                    }
                });
            }
        },
        error: function(error) {
            console.error('Error al cargar ventas por método pago:', error);
        }
    });
}

function cargarVentasPorDia(fechaInicio, fechaFin) {
    $.ajax({
        url: '/Indicadores/ObtenerVentasPorDia',
        type: 'POST',
        data: { fechaInicio: fechaInicio, fechaFin: fechaFin },
        dataType: 'json',
        success: function(response) {
            console.log('Respuesta Ventas por Día:', response);
            if (response.data && response.data.length > 0) {
                var labels = response.data.map(x => {
                    // Parsear fecha desde formato dd/MM/yyyy o ISO
                    var fechaStr = x.Fecha;
                    console.log('Fecha original:', fechaStr, 'Tipo:', typeof fechaStr);
                    var fecha;
                    
                    if (typeof fechaStr === 'string' && fechaStr.includes('/')) {
                        // Formato dd/MM/yyyy
                        var partes = fechaStr.split('/');
                        fecha = new Date(partes[2], partes[1] - 1, partes[0]);
                    } else {
                        // Formato ISO o timestamp
                        fecha = new Date(fechaStr);
                    }
                    
                    console.log('Fecha parseada:', fecha);
                    return fecha.toLocaleDateString('es-AR', { day: '2-digit', month: '2-digit' });
                });
                var valores = response.data.map(x => x.TotalVendido);
                
                if (chartVentasPorDia) chartVentasPorDia.destroy();
                
                var ctx = document.getElementById('chartVentasPorDia').getContext('2d');
                chartVentasPorDia = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Ventas Diarias',
                            data: valores,
                            borderColor: '#36a2eb',
                            backgroundColor: 'rgba(54, 162, 235, 0.1)',
                            fill: true,
                            tension: 0.4
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: true, position: 'top' },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        return 'Total: ' + formatearPrecio(context.parsed.y);
                                    }
                                }
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    callback: function(value) {
                                        return '$' + value.toLocaleString('es-AR');
                                    }
                                }
                            }
                        }
                    }
                });
            }
        },
        error: function(error) {
            console.error('Error al cargar ventas por día:', error);
        }
    });
}

function cargarTopClientes(fechaInicio, fechaFin) {
    $.ajax({
        url: '/Indicadores/ObtenerTopClientes',
        type: 'POST',
        data: { fechaInicio: fechaInicio, fechaFin: fechaFin },
        dataType: 'json',
        success: function(response) {
            // Destruir DataTable si ya existe
            if ($.fn.DataTable.isDataTable('#tableTopClientes')) {
                $('#tableTopClientes').DataTable().destroy();
            }
            
            var tbody = $("#tableTopClientes tbody");
            tbody.empty();
            
            if (response.data && response.data.length > 0) {
                response.data.forEach(function(item) {
                    var row = $('<tr>');
                    
                    var tdCliente = $('<td>').attr('data-order', item.Cliente);
                    tdCliente.html('<strong>' + item.Cliente + '</strong><br><small class="text-muted">' + item.NumeroDocumento + '</small>');
                    
                    var tdCantidad = $('<td>').addClass('text-center').attr('data-order', item.CantidadCompras).text(item.CantidadCompras);
                    
                    var tdTotal = $('<td>').addClass('text-right').attr('data-order', item.TotalComprado);
                    tdTotal.html('<strong>' + formatearPrecio(item.TotalComprado) + '</strong>');
                    
                    row.append(tdCliente).append(tdCantidad).append(tdTotal);
                    tbody.append(row);
                });
            }
            
            // Inicializar DataTable
            $('#tableTopClientes').DataTable({
                language: {
                    url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json'
                },
                order: [[2, 'desc']],
                paging: false,
                scrollX: false,
                autoWidth: true,
                responsive: false,
                info: false,
                columnDefs: [
                    { width: "50%", targets: 0 },
                    { width: "20%", targets: 1 },
                    { width: "30%", targets: 2 }
                ],
                dom: '<"row"<"col-sm-12"f>>' +
                     '<"row"<"col-sm-12"tr>>'
            });
        },
        error: function(error) {
            console.error('Error al cargar top clientes:', error);
        }
    });
}

function cargarTopProductos(fechaInicio, fechaFin) {
    $.ajax({
        url: '/Indicadores/ObtenerTopProductos',
        type: 'POST',
        data: { fechaInicio: fechaInicio, fechaFin: fechaFin },
        dataType: 'json',
        success: function(response) {
            // Destruir DataTable si ya existe
            if ($.fn.DataTable.isDataTable('#tableTopProductos')) {
                $('#tableTopProductos').DataTable().destroy();
            }
            
            var tbody = $("#tableTopProductos tbody");
            tbody.empty();
            
            if (response.data && response.data.length > 0) {
                response.data.forEach(function(item) {
                    var row = $('<tr>');
                    
                    var tdProducto = $('<td>').attr('data-order', item.Producto);
                    tdProducto.html('<strong>' + item.Producto + '</strong><br><small class="text-muted">' + item.Codigo + '</small>');
                    
                    var tdCantidad = $('<td>').addClass('text-center').attr('data-order', item.CantidadVendida).text(item.CantidadVendida + ' uds.');
                    
                    var tdTotal = $('<td>').addClass('text-right').attr('data-order', item.TotalVendido);
                    tdTotal.html('<strong>' + formatearPrecio(item.TotalVendido) + '</strong>');
                    
                    row.append(tdProducto).append(tdCantidad).append(tdTotal);
                    tbody.append(row);
                });
            }
            
            // Inicializar DataTable
            $('#tableTopProductos').DataTable({
                language: {
                    url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json'
                },
                order: [[2, 'desc']],
                paging: false,
                scrollX: false,
                autoWidth: true,
                responsive: false,
                info: false,
                columnDefs: [
                    { width: "50%", targets: 0 },
                    { width: "20%", targets: 1 },
                    { width: "30%", targets: 2 }
                ],
                dom: '<"row"<"col-sm-12"f>>' +
                     '<"row"<"col-sm-12"tr>>'
            });
        },
        error: function(error) {
            console.error('Error al cargar top productos:', error);
        }
    });
}

function cargarComprasPorProveedor(fechaInicio, fechaFin) {
    $.ajax({
        url: '/Indicadores/ObtenerComprasPorProveedor',
        type: 'POST',
        data: { fechaInicio: fechaInicio, fechaFin: fechaFin },
        dataType: 'json',
        success: function(response) {
            if (response.data && response.data.length > 0) {
                var labels = response.data.map(x => x.Proveedor);
                var valores = response.data.map(x => x.TotalComprado);
                
                if (chartComprasPorProveedor) chartComprasPorProveedor.destroy();
                
                var ctx = document.getElementById('chartComprasPorProveedor').getContext('2d');
                chartComprasPorProveedor = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Compras',
                            data: valores,
                            backgroundColor: ['#ff6384', '#36a2eb', '#4bc0c0', '#ff9f40', '#9966ff', '#ffcd56'],
                            borderRadius: 8
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        return formatearPrecio(context.parsed.y);
                                    }
                                }
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    callback: function(value) {
                                        return '$' + value.toLocaleString('es-AR');
                                    }
                                }
                            }
                        }
                    }
                });
            }
        },
        error: function(error) {
            console.error('Error al cargar compras por proveedor:', error);
        }
    });
}

function cargarComprasPorDia(fechaInicio, fechaFin) {
    $.ajax({
        url: '/Indicadores/ObtenerComprasPorDia',
        type: 'POST',
        data: { fechaInicio: fechaInicio, fechaFin: fechaFin },
        dataType: 'json',
        success: function(response) {
            console.log('Respuesta Compras por Día:', response);
            if (response.data && response.data.length > 0) {
                var labels = response.data.map(x => {
                    // Parsear fecha desde formato dd/MM/yyyy o ISO
                    var fechaStr = x.Fecha;
                    console.log('Fecha original (compras):', fechaStr, 'Tipo:', typeof fechaStr);
                    var fecha;
                    
                    if (typeof fechaStr === 'string' && fechaStr.includes('/')) {
                        // Formato dd/MM/yyyy
                        var partes = fechaStr.split('/');
                        fecha = new Date(partes[2], partes[1] - 1, partes[0]);
                    } else {
                        // Formato ISO o timestamp
                        fecha = new Date(fechaStr);
                    }
                    
                    console.log('Fecha parseada (compras):', fecha);
                    return fecha.toLocaleDateString('es-AR', { day: '2-digit', month: '2-digit' });
                });
                var valores = response.data.map(x => x.TotalComprado);
                
                if (chartComprasPorDia) chartComprasPorDia.destroy();
                
                var ctx = document.getElementById('chartComprasPorDia').getContext('2d');
                chartComprasPorDia = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Compras Diarias',
                            data: valores,
                            borderColor: '#ff6384',
                            backgroundColor: 'rgba(255, 99, 132, 0.1)',
                            fill: true,
                            tension: 0.4
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: true, position: 'top' },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        return 'Total: ' + formatearPrecio(context.parsed.y);
                                    }
                                }
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    callback: function(value) {
                                        return '$' + value.toLocaleString('es-AR');
                                    }
                                }
                            }
                        }
                    }
                });
            }
        },
        error: function(error) {
            console.error('Error al cargar compras por día:', error);
        }
    });
}

function cargarTopProveedores(fechaInicio, fechaFin) {
    $.ajax({
        url: '/Indicadores/ObtenerTopProveedores',
        type: 'POST',
        data: { fechaInicio: fechaInicio, fechaFin: fechaFin },
        dataType: 'json',
        success: function(response) {
            // Destruir DataTable si ya existe
            if ($.fn.DataTable.isDataTable('#tableTopProveedores')) {
                $('#tableTopProveedores').DataTable().destroy();
            }
            
            var tbody = $("#tableTopProveedores tbody");
            tbody.empty();
            
            if (response.data && response.data.length > 0) {
                response.data.forEach(function(item) {
                    var row = $('<tr>');
                    
                    var tdProveedor = $('<td>').attr('data-order', item.Proveedor);
                    tdProveedor.html('<strong>' + item.Proveedor + '</strong><br><small class="text-muted">' + item.NumeroDocumento + '</small>');
                    
                    var tdCantidad = $('<td>').addClass('text-center').attr('data-order', item.CantidadCompras).text(item.CantidadCompras);
                    
                    var tdTotal = $('<td>').addClass('text-right').attr('data-order', item.TotalComprado);
                    tdTotal.html('<strong>' + formatearPrecio(item.TotalComprado) + '</strong>');
                    
                    row.append(tdProveedor).append(tdCantidad).append(tdTotal);
                    tbody.append(row);
                });
            }
            
            // Inicializar DataTable
            $('#tableTopProveedores').DataTable({
                language: {
                    url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json'
                },
                order: [[2, 'desc']],
                paging: false,
                scrollX: false,
                autoWidth: true,
                responsive: false,
                info: false,
                columnDefs: [
                    { width: "50%", targets: 0 },
                    { width: "20%", targets: 1 },
                    { width: "30%", targets: 2 }
                ],
                dom: '<"row"<"col-sm-12"f>>' +
                     '<"row"<"col-sm-12"tr>>'
            });
        },
        error: function(error) {
            console.error('Error al cargar top proveedores:', error);
        }
    });
}

function cargarTopProductosComprados(fechaInicio, fechaFin) {
    $.ajax({
        url: '/Indicadores/ObtenerTopProductosComprados',
        type: 'POST',
        data: { fechaInicio: fechaInicio, fechaFin: fechaFin },
        dataType: 'json',
        success: function(response) {
            // Destruir DataTable si ya existe
            if ($.fn.DataTable.isDataTable('#tableTopProductosComprados')) {
                $('#tableTopProductosComprados').DataTable().destroy();
            }
            
            var tbody = $("#tableTopProductosComprados tbody");
            tbody.empty();
            
            if (response.data && response.data.length > 0) {
                response.data.forEach(function(item) {
                    var row = $('<tr>');
                    
                    var tdProducto = $('<td>').attr('data-order', item.Producto);
                    tdProducto.html('<strong>' + item.Producto + '</strong><br><small class="text-muted">' + item.Codigo + '</small>');
                    
                    var tdCantidad = $('<td>').addClass('text-center').attr('data-order', item.CantidadComprada).text(item.CantidadComprada + ' uds.');
                    
                    var tdTotal = $('<td>').addClass('text-right').attr('data-order', item.TotalComprado);
                    tdTotal.html('<strong>' + formatearPrecio(item.TotalComprado) + '</strong>');
                    
                    row.append(tdProducto).append(tdCantidad).append(tdTotal);
                    tbody.append(row);
                });
            }
            
            // Inicializar DataTable
            $('#tableTopProductosComprados').DataTable({
                language: {
                    url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json'
                },
                order: [[2, 'desc']],
                paging: false,
                scrollX: false,
                autoWidth: true,
                responsive: false,
                info: false,
                columnDefs: [
                    { width: "50%", targets: 0 },
                    { width: "20%", targets: 1 },
                    { width: "30%", targets: 2 }
                ],
                dom: '<"row"<"col-sm-12"f>>' +
                     '<"row"<"col-sm-12"tr>>'
            });
        },
        error: function(error) {
            console.error('Error al cargar top productos comprados:', error);
        }
    });
}
