$(document).ready(function() {
  var nickname_container = '#user_nickname_input';
  var nickname_input = nickname_container + ' input#user_nickname';
  var div_id = ' + div#check_nickname_results';
  var was_search_box_length = 0;

  if ($(nickname_input).length > 0){

    function check_nickname(){
      if ($(nickname_input).val() != ''){
		    $.ajax
		    ({
			    url: gon.check_nickname,			  
			    data: {nickname: $(nickname_input).val()},
			    type: "POST",			
          dataType: 'json'
		    }).done(function(d) { 
          if ($(nickname_container + div_id + ' > span.check_nickname').length == 0){
            // not exists, so create div
            $(nickname_container + div_id).html('<span class="check_nickname"></span>');
          }else{
            // exists, so clear out
            $(nickname_container + div_id + ' > span.check_nickname').empty();
          }
          
          // add the result
          var html = '';
          if (d.is_duplicate == true){
            $(nickname_container + div_id + ' > span.check_nickname').addClass('duplicate').removeClass('not_duplicate');
            html = gon.nickname_duplicate;
          }else{
            $(nickname_container + div_id + ' > span.check_nickname').addClass('not_duplicate').removeClass('duplicate');
          }
          html += ' ' + gon.nickname_url + ' /author/' + d.permalink;
          
          $(nickname_container + div_id + ' > span.check_nickname').html(html);
          
        });    
      }else if ($(nickname_container + div_id + ' > span.check_nickname').length > 0){
        $(nickname_container + div_id + ' > span.check_nickname').empty().removeClass('not_duplicate').removeClass('duplicate');
      }
    }


    // perform search
    $(nickname_input).bind('keyup', debounce(function () {
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
