$(document).ready(function() {
  // add autocomplete for translator collaborator search
  function assign_translator_tokeninput(selector){
    $(selector).tokenInput(
      gon.collaborator_search,
      {
        method: 'POST',
        minChars: 2,
        tokenLimit: 1, // only allow one selection
        theme: 'facebook',
        allowCustomEntry: true,
        preventDuplicates: true,
        prePopulate: $('form#collaborators .translator_ids').data('load'),
        hintText: gon.tokeninput_collaborator_hintText,
        noResultsText: gon.tokeninput_collaborator_noResultsText,
        searchingText: gon.tokeninput_searchingText,
        resultsFormatter: function(item){ 
          return "<li><img src='" + item.img_url + "' title='" + item.name + "' height='28px' width='28px' /><div style='display: inline-block; padding-left: 10px;'><div>" + item.name + "</div></div></li>" 
        },        
        tokenFormatter: function(item) { 
          if (item.img_url == undefined){
            return "<li><p>" + item.name + "</p></li>" ;
          }else{
            return "<li><p><img src='" + item.img_url + "' title='" + item.name + "' height='50px' width='50px' /></p></li>" ;
          }
        }
      }
    ); 
  }

  function load_translator_form_row(){
    // add the form fields
    $('form#collaborators #translator-form-rows').append($('#translator-form-row-template').html());

    // update the index of the fields
    var index = $('form#collaborators #translator-form-rows .translator-form-row').length;
    $('form#collaborators #translator-form-rows .translator-form-row:last').html($('form#collaborators #translator-form-rows .translator-form-row:last').html().replace(/INDEX/g, index));

    // register the new fields
    $('form#collaborators #translator-form-rows .translator-form-row:last select').selectpicker();
    $('form#collaborators #translator-form-rows .translator-form-row:last select').selectpicker('val', $('#translator-form-row-template').data('default'));
    assign_translator_tokeninput('form#collaborators #translator-form-rows .translator-form-row:last input.translator_ids');
  }

  // add autocomplete for editor collaborator search
  $('form#collaborators #editor_ids').tokenInput(
    gon.collaborator_search,
    {
      method: 'POST',
      minChars: 2,
      theme: 'facebook',
      allowCustomEntry: true,
      preventDuplicates: true,
      prePopulate: $('form#collaborators #editor_ids').data('load'),
      hintText: gon.tokeninput_collaborator_hintText,
      noResultsText: gon.tokeninput_collaborator_noResultsText,
      searchingText: gon.tokeninput_searchingText,
      resultsFormatter: function(item){ 
        return "<li><img src='" + item.img_url + "' title='" + item.name + "' height='28px' width='28px' /><div style='display: inline-block; padding-left: 10px;'><div>" + item.name + "</div></div></li>" 
      },        
      tokenFormatter: function(item) { 
        if (item.img_url == undefined){
          return "<li><p>" + item.name + "</p></li>" ;
        }else{
          return "<li><p><img src='" + item.img_url + "' title='" + item.name + "' height='50px' width='50px' /></p></li>" ;
        }
      }
    }
  ); 
  
  // add autocomplete for translator collaborator search
  assign_translator_tokeninput('form#collaborators .translator_ids');
  
  // add another set of translator form fields
  $('form#collaborators a#add-translator').click(function(e){
    e.preventDefault();   

    load_translator_form_row();
  });

  // load a translator row when the page loads
  load_translator_form_row();

  // remove collaborator
  $('.current-collaborators a.remove-collaborator').click(function(e){
    console.log('remove collab!');
    e.preventDefault();   
    var ths = this;
    $.ajax
    ({
      url: $(ths).data('url'),        
      data: {user_id: $(ths).data('id')},
      type: "POST",     
      dataType: 'json'
    }).done(function(d) {
      var dng = 'alert-danger';
      var info = 'alert-info';
      var cls = dng;
      if (d.success){
        // hide user
        $(ths).closest('li').fadeOut();
        cls = info;
      }
      // show message
      $('li#' + $(ths).data('msg-id')).css('display', 'block').removeClass(dng).removeClass(info).addClass(cls).html(d.msg);
    });
  });

  // remove translator from form by removing the row
  $('form#collaborators').on('click', 'a.remove-translator', function(e){
    e.preventDefault();   
    $(this).closest('.translator-form-row').remove();

    // if there are no more translator rows, add a new one
    if ($('form#collaborators #translator-form-rows .translator-form-row').length == 0){
      load_translator_form_row();   
    }
  });
});