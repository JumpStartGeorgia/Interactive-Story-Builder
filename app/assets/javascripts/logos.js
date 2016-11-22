$(document).ready(function() {

  $('.table-logos').on('click','.tools .btn-up, .tools .btn-down',function(){
    var row = $(this).closest('tr');
    var where = $(this).data('direction');
    $.ajax
    ({
      url: $(this).data('url'),
      type: "POST",
      dataType: 'json'
    }).done(function(d){
      if(where == 'up')
      {
        if(row.prev().length)
        {
          $(row).insertBefore($(row).prev());
        }
      }
      else
      {
        if( row.next().length)
        {
          $(row).insertAfter($(row).next());
        }
      }
    }).error(function(e){ popuper(gon.fail_change_order,"error");});
  });

});