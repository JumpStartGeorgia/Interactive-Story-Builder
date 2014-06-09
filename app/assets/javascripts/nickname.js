$(document).ready(function() {
  var nickname_path = 'input#user_nickname';
  var was_search_box_length = 0;

  if ($(nickname_path).length > 0){

    function check_nickname(){
      if ($(nickname_path).val() != ''){
		    $.ajax
		    ({
			    url: gon.check_nickname,			  
			    data: {nickname: $(nickname_path).val()},
			    type: "POST",			
          dataType: 'json'
		    }).done(function(d) { 
          if ($(nickname_path + ' + div + span.check_nickname').length == 0){
            // not exists, so create div
            $(nickname_path + ' + div').after('<span class="check_nickname"></span>');
          }else{
            // exists, so clear out
            $(nickname_path + ' + div + span.check_nickname').empty();
          }
          
          // add the result
          var html = '';
          if (d.is_duplicate == true){
            $(nickname_path + ' + div + span.check_nickname').addClass('duplicate').removeClass('not_duplicate');
            html = gon.nickname_duplicate;
          }else{
            $(nickname_path + ' + div + span.check_nickname').addClass('not_duplicate').removeClass('duplicate');
          }
          html += ' ' + gon.nickname_url + ' /author/' + d.permalink;
          
          $(nickname_path + ' + div + span.check_nickname').html(html);
          
        });    
      }else if ($(nickname_path + ' + div + span.check_nickname').length > 0){
        $(nickname_path + ' + div + span.check_nickname').empty().removeClass('not_duplicate').removeClass('duplicate');
      }
    }


    // perform search
    $(nickname_path).bind('keyup', debounce(function () {
      // if text length is 1 or the length has not changed (e.g., press arrow keys), do nothing
      if ($(this).val().length == 1 || $(this).val().length == was_search_box_length) {
        return;
      } else {
        check_nickname();
      }
      was_search_box_length = $(this).val().length;
    }));
;

    
/*    $(nickname_path).focusout(function() {
      check_nickname();
    });
*/
    check_nickname();
  }
});
