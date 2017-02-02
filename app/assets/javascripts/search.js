
$(document).ready(function(){

  $('#users-datatable').dataTable({
    "processing": true,
   "serverSide": true,
   "ajax": $('#users-datatable').data('source'),
   "order": [[5, 'desc']],
   "language": {
     "url": gon.datatable_i18n_url
   },
   "columnDefs": [
      { orderable: false, targets: [-1] }
        ]
 });

  $('#theme-datatable').dataTable({
    "order": [[4, 'desc']],
    "language": {
      "url": gon.datatable_i18n_url
    },
    "columnDefs": [
       { orderable: false, targets: [0,-2, -1] }
    ]

  });

  $('#author-datatable').dataTable({
    "order": [[1, 'asc']],
    "language": {
      "url": gon.datatable_i18n_url
    },
    "columnDefs": [
       { orderable: false, targets: [0,-1] }
    ]
  });

  $('#highlight-datatable').dataTable({
    "order": [[1, 'asc']],
    "language": {
      "url": gon.datatable_i18n_url
    },
    "columnDefs": [
       { orderable: false, targets: [0,-1] }
    ]
  });
});
