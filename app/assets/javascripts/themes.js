$(function() {

  // load date picker for law published_at field
  $("input#theme_published_at").datepicker({
    dateFormat: 'yy-mm-dd'
  });

  if (gon.published_at !== undefined && gon.published_at.length > 0){
    $("input#theme_published_at").datepicker("setDate", new Date(gon.published_at));
  }

  // if record is published, show pub date field by default
  if ($('input:radio[name="theme[is_published]"]:checked').val() === 'true') {
    $('#theme_published_at_input').show();
    $('#theme_show_home_page_input').show();    
  } else {
    $('#theme_published_at_input').hide();
    $('#theme_show_home_page_input').hide();
  }

  // if record is marked as published, show pub date field
  $('input:radio[name="theme[is_published]"]').click(function(){
    if ($(this).val() === 'true'){
      // show url textbox
      $('#theme_published_at_input').show(300);
      $('#theme_show_home_page_input').show(300);
    } else {
      // clear and hide pub date textbox
      $('#theme_published_at').val('');
      $('#theme_show_home_page_false').prop('checked', true);
      $('#theme_published_at_input').hide(300);
      $('#theme_show_home_page_input').hide(300);
    }
  });

});