
var tabladata;



$(document).ready(function () {

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
    
    // Establecer rango de fechas: último mes hasta hoy
    var fechaFin = ObtenerFecha();
    var fechaInicio = ObtenerFechaHaceUnMes();
    
    $("#txtFechaInicio").val(fechaInicio);
    $("#txtFechaFin").val(fechaFin);


    var urlCompleta = $.MisUrls.url._ObtenerVentas + "?codigo=&fechainicio=" + fechaInicio + "&fechafin=" + fechaFin + "&numerodocumento=&nombres=";
    console.log("URL de petición:", urlCompleta);
    
    tabladata = $('#tbVentas').DataTable({
        "ajax": {
            "url": urlCompleta,
            "type": "GET",
            "datatype": "json",
            "dataSrc": function(json) {
                console.log("Datos de ventas recibidos:", json);
                if (json.error) {
                    console.error("Error en el servidor:", json.error);
                }
                if (json.data) {
                    console.log("Cantidad de registros:", json.data.length);
                }
                return json.data || [];
            },
            "error": function(xhr, error, thrown) {
                console.error("Error en la petición AJAX:", error, thrown);
                console.error("Respuesta del servidor:", xhr.responseText);
            }
        },
        "columns": [
            {
                "data": "IdVenta", render: function (data) {
                    return "<button class='btn btn-success btn-sm ml-2' type='button' onclick='Imprimir(" + data + ")'><i class='far fa-clipboard'></i> Ver</button>"
                }
            },
            { "data": "TipoDocumento" },
            { "data": "Codigo" },
            { 
                "data": "FechaRegistro",
                "render": function(data, type, row) {
                    // Para ordenamiento, usar VFechaRegistro (DateTime)
                    // Para display, usar FechaRegistro (string formateado)
                    if (type === 'sort' || type === 'type') {
                        return row.VFechaRegistro;
                    }
                    return data;
                }
            },
            {
                "data": "oCliente", render: function (data) {
                    return data.NumeroDocumento
                }
            },
            {
                "data": "oCliente", render: function (data) {
                    return data.Nombre
                }
            },
            {
                "data": "TotalCosto", render: function (data) {
                    // Formatear como $X.XXX,XX (punto para miles, coma para decimales)
                    var numero = parseFloat(data).toFixed(2);
                    var partes = numero.split('.');
                    var entero = partes[0].replace(/\B(?=(\d{3})+(?!\d))/g, ".");
                    var decimal = partes[1];
                    return "$" + entero + "," + decimal;
                }
            },


        ],
        "language": {
            "url": $.MisUrls.url.Url_datatable_spanish
        },
        "order": [[3, "desc"]], // Orden por defecto: Fecha descendente (más recientes primero)
        responsive: true
    });

    // Evento para cambiar orden de la tabla
    $('#cboOrdenVenta').on('change', function () {
        var orden = $(this).val();
        if (orden == 'asc') {
            tabladata.order([[3, 'asc']]).draw(); // Más antiguos primero
        } else {
            tabladata.order([[3, 'desc']]).draw(); // Más recientes primero
        }
    });

});




function buscar() {

    if ($("#txtFechaInicio").val().trim() == "" || $("#txtFechaFin").val().trim() == "") {
        swal("Mensaje", "Debe ingresar fechas", "warning")
        return;
    }

    tabladata.ajax.url($.MisUrls.url._ObtenerVentas + "?" +
        "codigo=" + $("#txtCodigoVenta").val().trim() +
        "&fechainicio=" + $("#txtFechaInicio").val().trim() +
        "&fechafin=" + $("#txtFechaFin").val().trim() +
        "&numerodocumento=" + $("#txtDocumentoCliente").val() +
        "&nombres=" + $("#txtNombreCliente").val()).load();
}

function ObtenerFecha() {

    var d = new Date();
    var month = d.getMonth() + 1;
    var day = d.getDate();
    var output = (('' + day).length < 2 ? '0' : '') + day + '/' + (('' + month).length < 2 ? '0' : '') + month + '/' + d.getFullYear();

    return output;
}

function ObtenerFechaHaceUnMes() {
    var d = new Date();
    d.setMonth(d.getMonth() - 1); // Restar un mes
    var month = d.getMonth() + 1;
    var day = d.getDate();
    var output = (('' + day).length < 2 ? '0' : '') + day + '/' + (('' + month).length < 2 ? '0' : '') + month + '/' + d.getFullYear();

    return output;
}


function Imprimir(id) {

    var url = $.MisUrls.url._DocumentoVenta + "?IdVenta=" + id;
    window.open(url);

}