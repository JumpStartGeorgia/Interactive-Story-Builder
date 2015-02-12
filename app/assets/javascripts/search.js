
$(document).ready(function(){
  $.extend( $.fn.dataTableExt.oStdClasses, {
      "sWrapper": "dataTables_wrapper form-inline"
  });
  
  $('#users-datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "bDestroy": true,
    "bAutoWidth": false,
    "sAjaxSource": $('#users-datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aaSorting": [[5, 'desc']],
    "columnDefs": [
       { orderable: false, targets: [0,-1] }
    ]
  });

  $('#theme-datatable').dataTable({
    "dom": '<"top"lf>t<"bottom"pi><"clear">',
    "order": [[4, 'desc']],
    "language": {
      "url": gon.datatable_i18n_url
    },
    "columnDefs": [
       { orderable: false, targets: [0,-2, -1] }
    ]

  });

  $('#author-datatable').dataTable({
    "dom": '<"top"lf>t<"bottom"pi><"clear">',
    "order": [[1, 'asc']],
    "language": {
      "url": gon.datatable_i18n_url
    },
    "columnDefs": [
       { orderable: false, targets: [0,-1] }
    ]

  });

});
