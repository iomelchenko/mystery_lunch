$(document).on('turbolinks:load', function() {
	var groupColumn = 0;

    $('#meetings-table').DataTable({
        sPaginationType: "full_numbers",
        bJQueryUI: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#meetings-table').data('source'),
        columnDefs: [
            { visible: false, targets: groupColumn }
        ],
        order: [[ groupColumn, 'asc' ]],
        drawCallback: function ( settings ) {
            var api = this.api();
            var rows = api.rows( {page:'current'} ).nodes();
            var last=null;

            api.column(groupColumn, {page:'current'} ).data().each( function ( group, i ) {
                if ( last !== group ) {
                    $(rows).eq( i ).before(
                        '<tr class="meeting-group bg-info"><td colspan="5">'+group+'</td></tr>'
                    );

                    last = group;
                }
            } );
        }
    });
} );
