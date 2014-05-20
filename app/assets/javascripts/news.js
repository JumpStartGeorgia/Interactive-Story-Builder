$(document).ready(function(){
  if (gon.news_form){
  
		// load the date time pickers
		$('#news_published_at').datepicker({
				dateFormat: 'dd/mm/yy',
		});
		if (gon.published_at !== undefined && gon.published_at.length > 0)
		{
			$("#news_published_at").datepicker("setDate", new Date(gon.published_at));
		}
  
  
		// if record is published, show pub date field by default
		if ($('input:radio[name="news[is_published]"]:checked').val() === 'true') {
			$('#news_published_at_input').show();
		} else {
			$('#news_published_at_input').hide();
		}

		// if record is marked as published, show pub date field
		$('input:radio[name="news[is_published]"]').click(function(){
			if ($(this).val() === 'true'){
				// show url textbox
			  $('#news_published_at_input').show(300);
			} else {
				// clear and hide pub date textbox
				$('#news_published_at').attr('value', '');
			  $('#news_published_at_input').hide(300);
			}
		});
  
  }

});
