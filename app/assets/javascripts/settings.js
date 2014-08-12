// enable form fields for the provided type
function enable_notifications(type){
	$('#' + type + '_notifications input').removeAttr('disabled');
	$('#' + type + '_notifications select').removeAttr('disabled');
	$('#' + type + '_notifications').css('opacity', 1.0);
	$('#' + type + '_notifications').css('filter', 'alpha(opacity=100)');
}

function disable_all_fields(type){
	$('#' + type + '_notifications input').attr('disabled', 'disabled');
	$('#' + type + '_notifications select').attr('disabled', 'disabled');
	$('#' + type + '_notifications').fadeTo('fast', 0.5);
}

function enable_all_fields(type){
	$('#' + type + '_notifications input').removeAttr('disabled');
	$('#' + type + '_notifications select').removeAttr('disabled');
	$('#' + type + '_notifications').fadeTo('fast', 1.0);
}

function all_clicked(type){
	$('input#' + type + '_none').removeAttr('checked');
	$('select#' + type + '_categories').val([]);
  $("select#" + type + "_categories").selectpicker('deselectAll');
}

function none_clicked(type){
	$('input#' + type + '_all').removeAttr('checked');
	$('select#' + type + '_categories').val([]);
  $("select#" + type + "_categories").selectpicker('deselectAll');
}

function categories_clicked(type){
	$('input#' + type + '_all').removeAttr('checked');
	$('input#' + type + '_none').removeAttr('checked');
}

$(document).ready(function(){
	if (gon.notifications){
		if (gon.enable_notifications) {
			// enable new visual and idea form fields
			enable_notifications('language');
			enable_notifications('new_story');
			enable_notifications('story_comment');
			enable_notifications('news');
			enable_notifications('following');
		}

		// if want all notifications turn on fields
		// else, turn them off
		$("input[name='enable_notifications']").click(function(){
			if ($(this).val() === 'true') {
			  enable_all_fields('language');
			  enable_all_fields('new_story');
			  enable_all_fields('story_comment');
			  enable_all_fields('news');
			  enable_all_fields('following');
			} else {
			  disable_all_fields('language');
			  disable_all_fields('new_story');
			  disable_all_fields('story_comment');
			  disable_all_fields('news');
			  disable_all_fields('following');
			}
		});


		// register click events to clear out other form fields
		// for new stories
		$('input#stories_all').click(function(){
			all_clicked('stories');
		});
		$('input#stories_none').click(function(){
			none_clicked('stories');
		});
    $("select#stories_categories").bind("change", function(event, ui){
			categories_clicked('stories');
    });

    // if user clicks on followed user, change the selection value
    $('#following_notifications #following_user_list li').click(function(){
      var radios = $(this).find('input[type="radio"]');
      var current_value = $(this).find('input[type="radio"]:checked').val();
      if (current_value == 'true'){
        $(radios).filter('[value="false"]').prop('checked', true);
        $(this).addClass('unfollow');
        $(this).attr('title', $(this).data('follow'));
      }else{
        $(radios).filter('[value="true"]').prop('checked', true);
        $(this).removeClass('unfollow');
        $(this).attr('title', $(this).data('unfollow'));
      }
    });

	}

});

