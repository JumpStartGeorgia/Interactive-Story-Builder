//= require tinymce
/* global tinyMCE, $ */
var section_id = -1;
var item_id = -1;

var el_type = 'section';
var selectedType = 'story';
var method = 'n';
var tester = null;
var story_tree = null;
var section_types = ['content','media','slideshow','embed_media','youtube', 'infographic'];
var client = null;
$(document).ready(function() {

  calculate_workspace();
  $(window).resize(function() {
    calculate_workspace();
  });
   $('.storytree-toggle').click(function(){
      var t = $(this).parent();
      var sidebarWidth = t.width();
      var newLeft = t.hasClass('o') ? -1*sidebarWidth : 0;
      var content = $('.builder-wrapper .content .workplace');
      t.animate({'left': newLeft},
         {
            duration:2000,
            complete:function()
            {
               t.toggleClass('o c');
            },
            step:function(a,b)
            {
               content.css('paddingLeft',sidebarWidth + a);
            }
         }
      );
   });

   $(document).on('click','.btn-edit-story',function(e) {
      e.preventDefault();
    getObject('select','story');
   });

   $('.story-tree ul').on('click','li.item > .box > .title',function(e) {
      e.preventDefault();
      var tmpId = $(this).parent().parent().attr('id');
      $('.story-tree ul li').removeClass('active');
      $('.story-tree ul li.item[id='+tmpId+']').addClass('active');
      getObject('select', 'section', tmpId);
       //getStory(section_id);
       return false;
   });
   $('.story-tree ul').on('click','li.item > .box > .collapser',function(e) {
      e.preventDefault();
      var tmpId = $(this).parent().parent().attr('id');
      var t = $('.story-tree ul li.item[id='+tmpId+']').toggleClass('open').hasClass('open');
      $(this).text( t ? "-" : "+");
      $(this).parent().parent().children('ul').toggleClass("opened closed");
      return false;
   });

   $('.story-tree ul').on('click','li.item > ul > li.sub > div > .sub-l',function(e) {
      e.preventDefault();
      var cur = $(this).parent().parent();
      var par = cur.parent().parent();
      var tmpId = par.attr('id');
      var tmpSubId = cur.attr('id');
      var tmpType = par.attr('data-type');

      $('.story-tree ul li').removeClass('active');
      cur.parent().find('li#'+tmpSubId).addClass('active');
      getObject('select', tmpType, tmpId, tmpSubId);

      //getStory(section_id,item_id);
      if($( "#slideshowAssetFiles" ).length > 0 )
       $( "#slideshowAssetFiles" ).sortable({ items: "> div" });
       return false;
   });

  // when media type changes, show the correct file fields
   $('.story-viewer').on('change','input[name="medium[media_type]"]:radio',function(){

    var b = $(this).val()==1;
    var form = $('form.medium');
    form.find('#mediaImageBox').toggle(b);
    form.find('#mediaVideoBox').toggle(!b);

    // make sure the file fields are reset when the option changes
    form.find('input#mediaImage, input#mediaVideo').wrap('<form>').parent('form').trigger('reset');
    form.find('input#mediaImage, input#mediaVideo').unwrap();

	});

  // when infographic type changes, show the correct fields
  $('.story-viewer').on('change','input[name="infographic[subtype]"]:radio',function(){
    // 1 = static, 2 = dynamic
    var b = $(this).val()==1;
    var form = $('form.infographic');
    form.find('#infographicStaticBox').toggle(b);
    form.find('#infographicDynamicBox').toggle(!b);

    // make sure the file fields are reset when the option changes
    form.find('input#infographicStatic, input#infographicDynamic').wrap('<form>').parent('form').trigger('reset');
    form.find('input#infographicStatic, input#infographicDynamic').unwrap();
    // if render inline, show size block, else show image
    if (b){
      $('input#infographicDynamicUrl').val('');
    } else{
      if (form.find('input[name="infographic[dynamic_render]"]:checked').val() == '1'){
        form.find('#dynamic-size').toggle(!b);
      }else if (form.find('input[name="infographic[dynamic_render]"]:checked').val() == '2'){
        form.find('#infographicStaticBox').toggle(!b);
        form.find('#dynamic-size').toggle(b);
      }
    }

    // when the infographic type is changed, update the translation infographic type to match
    form.find('input.translation-subtype').val($(this).val());
  });

  // when infographic dynamic render changes, show the correct fields
  $('.story-viewer #infographicDynamicBox').on('change','input[name="infographic[dynamic_render]"]:radio',function(){
    // 1 = inline, 2 = popup
    var b = $(this).val()==1;
    var form = $('form.infographic');
    form.find('#dynamic-size').toggle(b);
    form.find('#infographicStaticBox').toggle(!b);

    // reset the size fields if this is popup
    if (!b){
      $('input#infographicDynamicWidth').val('');
      $('input#infographicDynamicHeight').val('');
    }
  });
  // when section type is media show background input else hide it
  $(".story-viewer").on("change", "input[name='section[type_id]']:radio", function (){
    $("#section_background_input").toggleClass("hidden", +$(this).val() !== 2);
  });

  $(".builder-wrapper .workplace").on("click", "#embed_source_url, #embed_source_code", function () {
    var t = $(this),
      type = t.val(),
      is_url = type === "url";

    $(".embed_based_on_url").toggleClass("hidden", !is_url);
    $(".embed_based_on_code").toggleClass("hidden", is_url);
    $("#embedMediaUrl, #embedMediaCode").val("");
  });
  $('.builder-wrapper .workplace').on('click', '.story-page1 #btnOlly, .story-page2 #btnOlly', function(){
    if($("[name=embed_source]:checked").val() === "url") {
      ths = $('#embedMediaUrl');
       url = $(ths).val();
      resetEmbedForm();

       if (url.length > 0 && isUrl(url)){
        olly.embed(url, document.getElementById("embedMediaResult"), 'timerOllyCompelte', 'ollyFail');
       }else{
        ollyFail();
       }
     }
     else {
      $("#embedMediaResult").html($("#embedMediaCode").val());
      $('#embedMediaButtons').show();
     }
   });
  // when review menu item clicked, open modal
  // and push in review key and story title
  $(document).on('click', '#btnReviewer', function(e){
     e.preventDefault();
    var v = $('.navbar-storybuilder');
    $("<div>"+reviewer.replace('[title]', $(this).data('title')).replace('[url]', $(this).data('reviewer-key')).replace('[url]', $(this).data('reviewer-key')) + "</div>").modalos({
      topOffset: $(v).position().top + $(v).height() + 30,
      width: 640
    });
    // for permalink copy
    client = new ZeroClipboard(document.getElementById("copy-button"));
    client.on( "ready", function( readyEvent ) {
      client.on( "aftercopy", function( event ) {
        document.getElementById('copied').style.display = 'block';
      });
    });
      return true;
  });

  $(document).on('click', '.btnPublish', function(e){
    e.preventDefault();
    if (!confirm(gon.confirm_publish)) return true;
    var a = $(this);
    var url = $(this).data('link');
    if ($(this).data('sl')){
      url += "?sl=" + $('.toolbar select#translateTo').val();
    }
      $.ajax(
      {
         dataType: "json",
         url: url}).done(
         function(d)
      {
        if(typeof(d.e) !== 'undefined' && d.e)
        {
          if(a.closest('.story-edit').length) a.closest('.story-edit').next('.story-message').html(d.msg).fadeIn(1000);
          else popuper(d.msg,'error');
        }
        else
        {
          if(a.closest('.story-edit').length) a.find('span:last-child').text(d.link).attr('title',d.title);
          else
          {
            a.find('span:last-child').attr('title',d.link + ' ' + d.title );
            a.toggleClass('btn-publish btn-publish-disabled');
          }

          // if this is translate publish button and percent is 100%, show button still, else hide
          if ($(a).data('sl')){
            if ($(a).data('percent') == '100%'){
              $(a).removeClass('hide');
            }else{
              $(a).addClass('hide');
            }
          }
        }
         });
      return true;
  });
   $('.story-edit-menu ul.nav li > ul.dropdown-menu li').click(function(){$(this).closest('.story-edit').next('.story-message').html("").hide();});

    $(document).on('click', '.preview', function(e){
          e.preventDefault();

        var ml = $('#' + $(this).attr('data-modalos-id'));
        var v = $('.navbar-storybuilder');
        var type = $(this).attr('data-type');
        var output = '';
        var opts = null;
        var opts_def =
        {
         topOffset: $(v).position().top + $(v).height() + 30,
         contentscroll:false,
         width:640,
         margins:0,
         paddings:0,
         klass: 'close-outside'
        };

        if(type == 'image')
        {
          output = "<img src='" +  $(this).attr('data-image-path') + "' style='width:640px;'/>";
        }
        else if(type == 'video')
        {
         output = "<video preload='auto' width='640px' height='auto' controls>" +
                     "Your browser does not support this video." +
                     "<source src='"+$(this).attr('data-video-path')+ "' type='"+$(this).attr('data-video-type')+"'>" +
                     "</video>";
         opts = {
            before_close:function(t)
            {
               $(t).find('video').each(function(){ this.pause(); })
               $(t).find('audio').each(function(){ this.pause(); })
            }
         };
        }
      else if(type == 'infographic')
      {
        output = "<img src='" +  $(this).attr('data-image-path') + "' style='width:640px;'/>";
        opts = { dragscroll: true };
      }
      else if(type == 'youtube')
      {
        previewYoutubeVideo($(this).parents('.viewer'),$(this).attr('data-loop'),$(this).attr('data-showinfo'));
        return true;
      }
      else if(type=='story')
      {
        var sl = $(this).attr('data-sl');
        if(sl)
          sl = "&sl=" + gon["translate_" + sl];

         output = "<iframe height='100%' width='100%' src='"+$(this).attr('data-link') + "?n=n"+ sl + "'></iframe>";
         opts = {
            fullscreen:true,
            aspectratio:true,
            klass:'close-outside story'
         };
      }
      $(output).modalos($.extend({}, opts_def, opts));
      return true;
  });

   $('.builder-wrapper .sidebar .story-tree').on('click','.tools .btn-up, .tools .btn-down',function()
   {
    var where = $(this).hasClass('btn-up') ? 'up' : 'down';
      var cur = $(this).closest('li');
      var sec_id = -1;
      var itm_id = -1;
      if(cur.hasClass('item'))
      {
         sec_id = cur.attr('id');
      }
      else
      {
         itm_id=cur.attr('id');
         var par = cur.parent().parent('li');
         sec_id = par.attr('id');
      }

      if(!(sec_id == -1 && itm_id == -1))
      {
         $.ajax
         ({
            url: where,
            data: {'s' : sec_id, 'i': itm_id },
            type: "POST",
            dataType: 'json'
         }).done(function(d)
         {
            var secT = $('.story-tree ul li.item[id='+ sec_id + ']');
            if(itm_id == -1)
            {
               if(where == 'up')
               {
                  if(secT.prev().length)
                  {
                    $(secT).insertBefore($(secT).prev());
                  }
               }
               else
               {
                  if( secT.next().length)
                  {
                    $(secT).insertAfter($(secT).next());
                  }
               }
            }
            else
            {
               subT = secT.find('ul li.sub[id='+itm_id+']');
               if(where == 'up')
               {
                  if( subT.prev().length)
                  {
                    $(subT).insertBefore($(subT).prev());
                  }
               }
               else
               {
                  if( subT.next().length)
                  {
                    $(subT).insertAfter($(subT).next());
                  }
               }
            }
         }).error(function(e){ popuper(gon.fail_change_order,"error");});
      }
   });

   $('.story-viewer').on("click",'.btn-up-slideshow', function() {
         var secT = $(this).parents('.fields');
         if( !secT.prev().length) return false;

         // if this is a new record and no id exists yet,
         // don't make ajax call, just move it
           if ($(this).data('id') == 0){
             if( secT.prev().length)
            {
               $(secT).insertBefore($(secT).prev());
            }
           }else{
             $.ajax
             ({
                url: 'up_slideshow',
                data: {asset_id: $(this).data('id')},
                type: "POST",
                  dataType: 'json'

             }).done(function(d)
             {
                if( secT.prev().length)
               {
                  $(secT).insertBefore($(secT).prev());
               }

             }).error(function(e){ popuper(gon.fail_change_order,"error");});
           }
   });


      $('.story-viewer').on("click",'.btn-down-slideshow', function() {
         var secT = $(this).parents('.fields');
         if( !secT.next().length) return false;

         // if this is a new record and no id exists yet,
         // don't make ajax call, just move it
        if ($(this).data('id') == 0){
           if( secT.next().length)
            {
              $(secT).insertAfter($(secT).next());
            }
      } else {
           $.ajax
           ({
              url: 'down_slideshow',
              data: {asset_id: $(this).data('id')},
              type: "POST",
                dataType: 'json'

           }).done(function(d)
           {
              if( secT.next().length)
               {
                 $(secT).insertAfter($(secT).next());
               }

           }).error(function(e){ popuper(gon.fail_change_order,"error");});
      }


   });
  $('.story-viewer').on("click",'.btn-remove-slideshow', function() {
    var t = $(this).closest(".fields").hide();
    t.find("input[type=hidden].destroy-asset").val("1");
  });

   $('.builder-wrapper .sidebar .story-tree').on('click','.tools .btn-remove',function()
   {
      var cur = $(this).closest('li');
      var par = cur;
      var id = -1;
      var sub_id = -1;
      var isItem = false;
      var type = cur.data('type');
      var pars = { '_method':'delete' };

      if(type.indexOf('_item')!= -1)
      {
         isItem = true;
         type = type.replace('_item','');
          sub_id=cur.attr('id');
         par = cur.parent().parent('li');
         id = par.attr('id');
         pars['sub_id'] = sub_id;
      }
      else
      {
         type = 'section';
         id = cur.attr('id');
      }
      pars['_id'] = id;
      pars['type'] = type;

      if (!confirm(gon.confirm_delete)) return true;

      $.ajax
      ({
         url: 'remove',
         data: pars,
         type: "POST",
         dataType: 'json'
      })
      .done(function(d)
      {
         if(!error(d))
         {
            //var secT = $('.story-tree ul li.item[id='+ id + ']');
            if(isItem)
            {
               if(cur.find('ul li').length == 1)
                  cur.parent().remove();
               else cur.remove();
            }
            else
            {
               par.remove();
            }

            $('.builder-wrapper .content .workplace .viewer').html('');
            if(cur.hasClass('active'))
            {
               item_id = -1;
               section_id = -1;
            }
         }
      })
      .error(function(e){ popuper(gon.fail_delete,"error"); });
   });


   $('.btn-create-section').click(function(e){ e.preventDefault(); getObject('create','section'); });


   $('.builder-wrapper .sidebar .story-tree').on('click','li.item > ul > .btn-create',function(e)
   {
    e.preventDefault();
    var cur = $(this).closest('li');
    var id = cur.attr('id');
    var type = cur.data('type');
      if(id == -1) { alert(gon.msgs_select_section); return true; }

      if( ['content','slideshow','embed_media','youtube', 'infographic'].indexOf(type) != -1 && cur.has('ul li').length==1 )
      {
         alert(gon.msgs_one_section_general);
      }
      else
      {
         getObject('create', type, id);
      }
   });

  // trigger the add content form if no sections exist
  if (gon.has_no_sections == true)
  {
    getObject('create','section');
  }
  else if (gon.is_section_page == true )
  {
    getObject('select','story');
  }

  var /*was_title_box_length,*/ was_permalink_box_length = 0;

  // if the title changes and there is no permalink or the permalink was equal to the old title,
  // add the title into the permalink show field
  // $(document).on('keyup','input#storyTitle', debounce(function()
  // {
  //   var staging = $('input#storyPermalinkStaging');
  //   var staging_val = staging.val();
  //   var t = $(this);
  //   var tv = t.val();
  //   var locale = $(this).closest('form').find('input#current_locale').val();
  //   if ((staging_val != '' && staging_val !== $(this).data('title-was')) ||
  //       tv.length == was_title_box_length) {
  //       console.log('upper');
  //     return;
  //   }
  //   else
  //   {
  //     t.data('title-was', tv);
  //     staging.val(tv);
  //     check_story_permalink(tv, locale);
  //     console.log('down');
  //   }
  //   was_title_box_length = tv.length;
  // }));
  // if the permalink staging field changes, use the text to generate a new permalink
  $(document).on("keyup", "input#storyPermalinkStaging", debounce(function () {
    // if text length is 1 or the length has not changed (e.g., press arrow keys), do nothing
    var t = $(this), tv = t.val();
    if(tv.length !== 1) {
      check_story_permalink(tv, t.closest("form").find("input#current_locale").val());
    }
    // was_permalink_box_length = l;
  }));




  // when the story locale changes, make sure the hidden locale field also changes
  $('#storyLocale').change(function(){
    $('input#storyHiddenLocale').val($('#storyLocale').val());
    $('input#current_locale').val($('#storyLocale').val());
  });




  // add autocomplete for tags
  if ($('#storyTagList').length > 0){
    $('#storyTagList').tokenInput(
      gon.tag_search,
      {
        method: 'POST',
        minChars: 2,
        theme: 'facebook',
        allowCustomEntry: true,
        preventDuplicates: true,
        prePopulate: $('#storyTagList').data('load'),
        hintText: gon.tokeninput_tag_hintText,
        noResultsText: gon.tokeninput_tag_noResultsText,
        searchingText: gon.tokeninput_searchingText
      }
    );
  }


  $('#translateFrom').change(function(){
      var fromLang = $(this).val();
      var toLang = $('#translateTo').val();
      // var which = 1;
      if(fromLang == toLang)
      {
         $('#translateTo option').each(function(i,d){
            if(d.value != fromLang)
            {
              // which = 0;
               $('#translateTo').val(d.value);
               $('#translateTo').selectpicker('refresh');
               gon.translate_to = d.value;
               return false;
            }
         });
      }
      gon.translate_from = fromLang;
      getObject('select',selectedType, section_id, item_id, 0);
      // call new language
  });
    $('#translateTo').change(function(){
      var fromLang = $('#translateFrom').val();
      var toLang = $(this).val();
      var which = 2;
      if(fromLang == toLang)
      {
        which = 0;
         gon.translate_from = $('#translateFrom').attr('data-default');
         $('#translateFrom').val(gon.translate_from);
           $('#translateFrom').selectpicker('refresh');
      }
       gon.translate_to = toLang;
      getObject('select',selectedType, section_id, item_id, which);

      get_translation_progress(toLang);
  });

  story_tree = $('.story-tree');

// copy paste for translation form fields
  $(document).on('mouseenter','.story-page2 input[type=text], .story-page2 input[type=url]', function(){
    var id = $(this).closest('.form-group').attr('id');
    $('.copy-paste').stop().css({'top':$(this).offset().top + 14,'left':$(this).offset().left-22 }).attr('data-id',id).fadeIn(500);
  });
  $(document).on('mouseleave','.story-page2 input[type=text], .story-page2 input[type=url]', function(){
    $('.copy-paste').fadeOut(5000);
  });
  $('.copy-paste').click(function(){
    var id = $(this).attr('data-id');
    var from = $('.story-page1 #' + id + ' input');
    var to = $('.story-page2 #' + id + ' input');
    if(from.length && from.val() != "")
    {
      to.val(from.val());
    }
  });
  $(".builder-wrapper .workplace").scroll(function () {
    var tinymceControl = tinyMCE.activeEditor.windowManager.editor.controlManager.controls;
    Object.keys(tinymceControl).forEach(function (k) {
      if(tinymceControl[k].hasOwnProperty("isMenuVisible") && tinymceControl[k]["isMenuVisible"] === 1) {
        tinymceControl[k].hideMenu();
      }
    });
  })
});

function show_story_permalink(d){
  var div = "#story_permalink", t = $(div + " > span.check_permalink");
  // show the permalink
  if (t.length == 0){ // not exists, so create div
    $(div).html("<span class=\"check_permalink\"></span>");
    t  = $(div + " > span.check_permalink");
  }
  else { // exists, so clear out
    t.empty();
  }

  // add the result
  var html = "", is_dup = d.is_duplicate;
  if (is_dup){ html = gon.story_duplicate; }
  html += " " + gon.story_url + " /" + d.permalink;

  t.toggleClass("duplicate", is_dup)
    .toggleClass("not_duplicate", !is_dup)
    .html(html);
}

function check_story_permalink (text, locale){
  if (text != ""){
    var data = {text: text};
    //,
      //url = window.location.href.split("/");

    // if (url[url.length-1] == "edit"){
    //   data.id = url[url.length-2];
    // }
    if(typeof gon.story_id !== "undefined") {
      data.id = gon.story_id;
    }
    // pass in locale if exists
    if (locale != undefined){
      data.sl = locale;
    }

    $.ajax
    ({
       url: gon.check_permalink,
       data: data,
       type: "POST",
      dataType: "json"
    }).done(function(d) {
      // record the new permalink
      $("input#storyPermalink").val(d.permalink);

      // show the permalink
      show_story_permalink(d);
    });
  }
  else{
    $("#story_permalink > span.check_permalink").empty().removeClass("not_duplicate").removeClass("duplicate");
  }
}


function resetEmbedForm(){
  $('#embedMediaCode').empty();
  $('#embedMediaResult').empty();
  $('#embedMediaButtons').hide();
  $('#embedMediaError').hide();
}
function ollyFail(){
  resetEmbedForm();
  $('#embedMediaUrl').focus();
  $('#embedMediaError').show();
}
function timerOllyCompelte() {
  if ($('#embedMediaResult').html().length > 0){
    $('#embedMediaCode').val($('#embedMediaResult').html());
    $('#embedMediaButtons').show();
  }else{
    setTimeout(function() {
        timerOllyCompelte();
    }, 500)
  }
}

function isUrl(s) {
  var regexp = /(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
  return regexp.test(s);
}

function getObject(method, type, id, sub_id, which)
{
  //console.log('getObject');
   method = typeof method !== 'undefined' ? method : '';  // n - new , s - select, r - remove, a - add
   type = typeof type !== 'undefined' ? type : '';
   id = typeof id !== 'undefined' ? id : -1;
   sub_id = typeof sub_id !== 'undefined' ? sub_id : -1;
   which = typeof which !== 'undefined' ? which : 0;
   selectedType = type;

//   console.log(method,type,id,sub_id,which);
   if(method == 'create') which = 1;
   var pars = { 'which': which };
   if(type == 'story')
   {

   }
   else if(type=='section')
   {
      section_id = id;
      item_id = -1;

      if(method == 'create')
      {
         section_id = -1;
         $('.story-tree ul li').removeClass('active');
      }
   }
   else if(section_types.indexOf(type) != -1)
   {
      section_id = id;
      item_id = sub_id;
      pars['sub_id'] = sub_id;
   }
   else return false;

   pars['_id'] = section_id;
   pars['method'] = method;
   pars['type'] = type;

   if(gon.translate) {
      pars['tr'] = true;
      pars['tr_from'] = gon.translate_from;
      pars['tr_to'] = gon.translate_to;
    }
// request data
   $.ajax
      ({
        url: 'get_data',
        data: pars,
        dataType: 'script',
        cache: true,
      }).error(function(e){console.log(e)}).done(function(){
         //if(el_type!='section' && method lo!= 'n')
           // $('.form-title .form-title-text').text($('.story-tree > ul > li.item[id='+section_id+'].open > ul > li.sub.active > div > .sub-l').text() + ": " + $('.form-title .form-title-text').text());
      });

   return true;
}

function add_fields(link, association, content) {
   var new_id = new Date().getTime();
   var regexp = new RegExp("new_" + association, "g")
    if (association == 'asset_files'){
      $('#slideshowAssetFiles').append(content.replace(regexp, new_id));
    }else if (association == 'infographic_datasources'){
      $('#infographicDataSources').append(content.replace(regexp, new_id));
    }
}
function error(v)
{
   return (v == null || typeof v === 'undefined' || !v.hasOwnProperty('e') || v.e == true);
}
function refresh()
{

}
function change_tree(d)
{
  //console.log('change_tree',d);
   var li = $("<li id='"+d.id+"' data-type='"+d.type+"' class='item open'>" +
               "<div class='box'>" +
                  "<div class='collapser'>-</div>" +
                  "<div class='s "+d.icon+"'></div>" +
                  "<div class='title'><span>"+d.title+"</span></div>" +
                  d.tools +
                  "<div class='storytree-arrow'><div class='arrow'></div></div>" +
               "</div>" +
               "<ul class='opened'>"+d.add_item+"</ul>" +
            "</li>");
   story_tree.find('ul li').removeClass('active'); // todo is it enough for reseting or section_id should be changed too ???
   story_tree.find('> ul').append(li);

  li.find('.box .title').trigger('click');
  if(d.select_next) select_next();
}
function change_sub_tree(d)
{
   var section = story_tree.find('ul li.item[id='+ d.id + ']');
   var li = $("<li id='"+d.sub_id+"' class='sub' data-type='"+d.type+"_item'><div><div class='sub-l'>"+d.title+"</div>"+(d.hasOwnProperty('tools') ? d.tools : '')+"<div class='storytree-arrow'><div class='arrow'></div></div></div></li>");

   if(d.type != 'media')
   {
      section.find('> ul > button').remove();
      section.find('ul').append(li);
   }
   else
   {
      li.insertBefore( section.find('> ul > button'));
   }
   story_tree.find('ul li').removeClass('active');
   li.find('.sub-l').trigger('click');
   if(d.select_next) select_next();
}

function which(v,html)
{
  $(v==2?".story-page2":".story-page1").hide().html(html).fadeIn('slow');
}
function calculate_workspace()
{
  if($(".builder-wrapper").length)
  {
    var bw = $(".builder-wrapper");
    var nav =  $('.nav-tabs');
    var t = bw.find('.toolbar');
    var topOffset = t.outerHeight()+t.offset().top;

    bw.height($(window).height()- nav.outerHeight()-nav.offset().top);

    var bwh = $(window).height()-topOffset;
    var content = bw.find("> .content");
    var toolbar = bw.find("> .toolbar");

    var sidebar = content.find("> .sidebar");
    var workplace = content.find("> .workplace");
    var tree =  sidebar.find("> .story-tree");


    tree.height(bwh);
    workplace.height(bwh);

    content.css('top',topOffset + 'px');
  }
}
function select_next()
{
  var tree = $('.story-tree');
  var t = tree.find('ul li.active');

  //console.log('active',t);
  if(t.length) // if there is active item
  {
    var child = t.find('ul li');
    //console.log(child.length);
    if(child.length) // select child element if exists
    {
      if(!t.hasClass('open')) // if childs list not opened yet open it
      {
        t.find('> .box > .collapser').trigger('click');
      }
      child.first().find('> div > .sub-l').trigger('click');
    }
    else // if has no child li elements
    {
      if(t.hasClass('sub')) // if element is sub
      {
        var next = t.next('li.sub');
        if(next.length) // if has sub brothers
        {
           next.find('> div > .sub-l').trigger('click');
        }
        else // if no brother should jump to next parent
        {
          next = t.closest('li.item').next('li.item')
          if(next.length)
          {
            if(!next.hasClass('open')) // if childs list not opened yet open it
            {
              next.find('> .box > .collapser').trigger('click');
            }
            next.find('> .box > .title').trigger('click');
            tree.get(0).scrollTop = tree.get(0).scrollTop + next.position().top;
          }
          else
          {
            getObject('create','section');
          }
        }
      }
      else // parent has no inner items so go to create page
      {
        t.find('ul > .btn-create').trigger('click');
        // next = t.next('li.item')
        // if(next.length)
        // {
        //   if(!next.hasClass('open')) // if childs list not opened yet open it
        //   {
        //     next.find('> .box > .collapser').trigger('click');
        //   }
        //   next.find('> .box > .title').trigger('click');
        //   tree.get(0).scrollTop = tree.get(0).scrollTop + next.position().top;
        // }
        // else
        // {

        // }
      }
    }
  }
  else // if nothing is selected
  {
    t = $('.story-tree ul li').first();
    if(t.length) // and if item exists
    {
      if(!t.hasClass('open')) // if childs list not opened yet open it
      {
        t.find('> .box > .collapser').trigger('click');
      }
      t.find('> .box > .title').trigger('click'); // simulate click to get data
    }
  }
}

// get the updated translation progress for this locale
function get_translation_progress(to_locale){
 $.ajax
    ({
      url: gon.translation_progress_url,
      data: {sl: to_locale},
      dataType: 'script'
    }).error(function(e){console.log(e)}).done(function(){
       //if(el_type!='section' && method != 'n')
         // $('.form-title .form-title-text').text($('.story-tree > ul > li.item[id='+section_id+'].open > ul > li.sub.active > div > .sub-l').text() + ": " + $('.form-title .form-title-text').text());
    });
}

// update the language switchers with the latest progress status for the provided locale
function update_translation_progress(progress, to_locale, percent, is_published){
  console.log('update translation progress');
  if ($('.toolbar select#translateTo').length > 0){
    var optionTo = $('.toolbar select#translateTo option[value="' + to_locale + '"]');
    var pickerTo = $('.toolbar select#translateTo + .bootstrap-select');
    var optionFrom = $('.toolbar select#translateFrom option[value="' + to_locale + '"]');
    var pickerFrom = $('.toolbar select#translateFrom + .bootstrap-select');
    var publishTo = $('.toolbar .right-view a.btnPublish');

    // if the to locale is in the progress list, let's update the text in the drop down list
    var match = $.grep(progress, function(x){
      return x.locale == to_locale;
    });
    // create percent
    if (match != undefined && percent != undefined && percent != ""){
      // found match, now need to udpate text
      var text;
      var orig_text = $(optionTo).html();
      if ($(optionTo).html().indexOf(' (') > -1){
        // already has percent, so need to replace
        text = $(optionTo).html().replace(/\s\(\d{1,3}%\)/,  ' (' +  percent + ')');
      }else{
        // not have percent, so need to add
        text = $(optionTo).html() + ' (' +  percent + ')'
      }
      $(optionTo).html(text);
      $(pickerTo).find(" > button").attr('title', text);
      $(pickerTo).find(" > button span.filter-option").html(text);
      $(pickerTo).find(" .dropdown-menu ul li a span.text:contains('" + orig_text + "')").html(text);
      $(pickerFrom).find(" .dropdown-menu ul li a span.text:contains('" + orig_text + "')").html(text);
      $(publishTo).attr('data-percent', percent);

      // if to is 100% or story is already published, then turn on publish button
      //console.log('percent = ' + percent + '; parseint = ' + parseInt(percent));
      if (parseInt(percent) >= 100 || is_published == 'true'){
        $(publishTo).toggleClass('btn-publish-disabled btn-publish').removeClass('hide');
      }else{
        $(publishTo).toggleClass('btn-publish btn-publish-disabled ').addClass('hide');
      }


    }else{
      // turn off pub button since there is no percent
      $(publishTo).toggleClass('btn-publish btn-publish-disabled ').addClass('hide');
    }
  }
}
function previewYoutubeVideo(t,loop,showinfo) // context
{
  var url = t.find('#youtubeUrl').val();
  t.find('#youtubeError').hide();
  var id;
  if(url.length == 11) id = url;
  else
  {
    var uri = url.match(/^(?:http(?:s)?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:(?:watch)?\?(?:.*&)?v(?:i)?=|(?:embed|v|vi|user)\/))([^\?&\"'>]+)/);
    if(typeof uri[1] !== 'undefined' && uri[1].length == 11)
      id = uri[1];
  }

  if(typeof id !== 'undefined')
  {
    $.ajax({
      url: "https://www.googleapis.com/youtube/v3/videos?key=" + gon.youtube_api_key + "&part=id&id=" + id,
      context: document.body,
      success: function(d){
         if(d.hasOwnProperty("items") && d.items.length > 0)
         {
              var playerVars = {};
              if(typeof loop !== 'undefined')
              {
                 playerVars['loop'] = loop;
              }
              else
              {
                if(t.find('#youtubeLoop').is(':checked')) playerVars['loop'] = 1; // def 0
              }
              if(typeof showinfo !== 'undefined')
              {
                 playerVars['showinfo'] = showinfo;
              }
              else
              {
                if(!t.find('#youtubeInfo').is(':checked')) playerVars['showinfo'] = 0; //def 1,  will not display information like the video title and uploader before the video starts playing.
              }
              playerVars['cc_load_policy'] = (t.find('#youtubeCC').is(':checked') ? 1 : 0); //def 1,  will not display information like the video title and uploader before the video starts playing.
              playerVars['hl'] = t.find('#youtubePlayerLang').val();
              playerVars['cc_lang_pref'] = t.find('#youtubeCCLang').val();
              playerVars['rel'] = 0;
              var v = $('.navbar-storybuilder');
              $("<div class='youtubePlayer'></div>").modalos({
                topOffset: $(v).position().top + $(v).height() + 30,
                width: 640,
                klass: 'close-outside',
                paddings:0,
                margins:0
              });
              loadYoutubeVideo($('.modalos-wrapper .youtubePlayer').get(0),id,640,360,playerVars);
         }
         else
         {
            t.find('#youtubeUrl').focus();
            t.find('#youtubeError').css('display','inline-block');
         }
      },
      error: function(d){
        t.find('#youtubeUrl').focus();
        t.find('#youtubeError').css('display','inline-block');
      }
    });
  }
}
function loadYoutubeVideo(element,videoId,width,height,playerVars)
{
  if (!youtubeApi()) {
    console.log("Youtube api is not loaded yet");
    return;
  }
   new YT.Player(
    element, {
      videoId: videoId,
      width: width,
      height: height,
      playerVars: playerVars,
      events:
      {
        onStateChange: function(event)
        {
          if (event.data == 1)
          {
            var locale = event.target.d.d.playerVars.cc_lang_pref;
            var load_policy = event.target.d.d.playerVars.cc_load_policy;
            if (locale != undefined && load_policy == 1)
            {
              event.target.loadModule("captions");  //Works for html5 ignored by AS3
              event.target.setOption("captions", "track", {"languageCode": locale});  //Works for html5 ignored by AS3
              event.target.loadModule("cc");  //Works for AS3 ignored by html5
              event.target.setOption("cc", "track", {"languageCode": locale});  //Works for AS3 ignored by html5
            }
          }
        },
        onError: function(){ console.log("onError",event); }
      }
    });
}
function youtubeApi()
{
  if (typeof(YT) === 'undefined' || typeof(YT.Player) === 'undefined')
  {
    var tag = document.createElement('script');
    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
    return false;
  }
  else return true;
}
youtubeApi();
