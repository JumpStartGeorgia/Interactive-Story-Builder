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


  // fancy select boxes with search capability
  if ($('.selectpicker').length > 0){
    $('.selectpicker').selectpicker();
  }

  // when story is selected, add it to the list of features and remove it from the select list
  $('select.add-story').change(function(){
    var index = Math.floor(Math.random() * (9999999999 - 10000000 + 1)) + 10000000;
    var id = $(this).val();
    var title = $(this).find('option:selected').data('content');
    var img = $(this).find('option:selected').data('image');

    // see if the story already exists, but is hidden
    var feature = $('#feature-container .feature[data-story-id="' + id + '"]');
    if ($(feature).length == 1){
      // reset position, move to end and turn on
      $(feature).find('.feature-actions input.input-position').attr('value', $('#feature-container .feature:visible').length);
      $(feature).find('.feature-actions input.input-delete').attr('value', '');
      $(feature).appendTo($('#feature-container'));
      $(feature).show();

    }else{
      // populate template and add to list
      var template = $('#feature-template').clone();
      $(template).find('.feature').attr('data-story-id', id);
      $(template).find('.feature-image img').attr('src', img);
      $(template).find('.feature-info').html(title);
      $(template).find('.feature-actions input.input-story-id').attr('value', id);
      $(template).find('.feature-actions input.input-position').attr('value', $('#feature-container .feature:visible').length+1);
      $(template).html($(template).html().replace(/FEATURE-INDEX/g, index));
      $('#feature-container').append($(template).html());

    }

    // update alt row colors
    $('#feature-container .feature:visible:odd').addClass('even-row').removeClass('odd-row');
    $('#feature-container .feature:visible:even').addClass('odd-row').removeClass('even-row');     


    // disable story in drop down
    $(this).find('option:selected').prop('disabled', true);
    $(this).val('');
    $(this).selectpicker('refresh');
    $(this).selectpicker('render');

    // hide no stories message
    $('#no_stories').hide();

  });

  // when remove button clicked, hide this item and update input field to delete
  // then show story in select list
  $('#feature-container').on('click', '.feature .btn-remove', function(e){
    e.preventDefault();   

    var story_id = $(this).closest('.feature-actions').find('input.input-story-id').val();
    $(this).closest('.feature-actions').find('input.input-delete').val('1');
    $(this).closest('.feature-actions').find('input.input-position').val('');
    $(this).closest('.feature').hide();

    // update alt row colors
    $('#feature-container .feature:visible:odd').addClass('even-row').removeClass('odd-row');
    $('#feature-container .feature:visible:even').addClass('odd-row').removeClass('even-row');     

    // show story in select list
    $('select.add-story option[value="' + story_id + '"]').prop('disabled', false);
    $('select.add-story').selectpicker('refresh');

    // if no more feature stories so no text
    if ($('#feature-container .feature:visible').length == 0){
      $('#no_stories').show();
    } else{
      $('#no_stories').hide();
    }   
  });

});

  // move the item up in the list and update the position values
  $('#feature-container').on('click', '.feature .btn-up', function(e){
    e.preventDefault();   

    // move the item
    var feature = $(this).closest('.feature');
    $(feature).insertBefore($(feature).prev());

    // update alt row colors
    $('#feature-container .feature:visible:odd').addClass('even-row').removeClass('odd-row');
    $('#feature-container .feature:visible:even').addClass('odd-row').removeClass('even-row');     

    // update the position values
    $(feature).find('.feature-actions input.input-position').attr('value', parseInt($(feature).find('.feature-actions input.input-position').attr('value'))-1);
    $(feature).next().find('.feature-actions input.input-position').attr('value', parseInt($(feature).next().find('.feature-actions input.input-position').attr('value'))+1);

  });

  // move the item down in the list and update the position values
  $('#feature-container').on('click', '.feature .btn-down', function(e){
    e.preventDefault();   

    // move the item
    var feature = $(this).closest('.feature');
    $(feature).insertAfter($(feature).next());

    // update alt row colors
    $('#feature-container .feature:visible:odd').addClass('even-row').removeClass('odd-row');
    $('#feature-container .feature:visible:even').addClass('odd-row').removeClass('even-row');     

    // update the position values
    $(feature).find('.feature-actions input.input-position').attr('value', parseInt($(feature).find('.feature-actions input.input-position').attr('value'))+1);
    $(feature).prev().find('.feature-actions input.input-position').attr('value', parseInt($(feature).prev().find('.feature-actions input.input-position').attr('value'))-1);

  });

