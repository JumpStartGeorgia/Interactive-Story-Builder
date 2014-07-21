// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require i18n
//= require i18n/translations
//= require jquery
//= require jquery_ujs
//= require modalos
//= require jquery.remotipart
//= require jquery.ui.core
//= require twitter/bootstrap



// window.onload =  function() 
// {
//   document.getElementById('search-input').blur();
// };
//  document.getElementById('search-input').onfocus = function(e)
//  {
//   console.log(e);
//  }
var mob = false;  
(function(a){mob=/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))})(navigator.userAgent||navigator.vendor||window.opera);

$(document).ready(function(){


  	// set focus to first text box on page
	if (gon.highlight_first_form_field){
	  $(":input:visible:enabled:first:not(.search-input)").focus();
	}

	// workaround to get logout link in navbar to work
	$('body')
		.off('click.dropdown touchstart.dropdown.data-api', '.dropdown')
		.on('click.dropdown touchstart.dropdown.data-api', '.dropdown form', function (e) { e.stopPropagation() });

  //for dropdown menu to open on hover

if(!mob){
  $(document).on({
    mouseenter: function () {
      $(this).closest('.dropdown-menu').stop(true, true).show();
      $(this).addClass('open'); 
      console.log("mouseenter");
    },
    mouseleave: function () {
      $(this).closest('.dropdown-menu').stop(true, true).hide();
      $(this).removeClass('open'); 
      console.log("mouseleave");
    }
  },'ul.nav li.dropdown-hover');

}

  // fancy select boxes with search capability
  if ($('.selectpicker').length > 0){
    $('.selectpicker').selectpicker({dropupAuto:false});
  }

  $('body').on('click','.modalSignIn, .modalForgotPassword, .modalRegistration', function(e) {   
      var ml = $(this).attr('data-modalos-id'); 
      var v = $('.navbar-story').length ? $('.navbar-story') : $('.navbar-storybuilder');            
      if($('#'+ml).length)
      {        
           $('#'+ml).modalos({topOffset: $(v).position().top + $(v).height() + 30, width:435, before_close:function(t){$(t).find('.alert').remove();}});     
      }
      else
      {   
        $.ajax({                 
          url: $(this).attr('href'),                  
        }).done(function(data) {                    
          $('body').append($('<div>').attr('id',ml).css('display','none').addClass($(this).attr('data-modalos-class')).html(data));                    
          $('#'+ml).modalos({topOffset: $(v).position().top + $(v).height() + 30, width:435});     
        });
      }
     
      e.preventDefault();
      e.stopPropagation();

      return false;
  });

  $('body').on('submit','#new_user', function ()
  {    
    var t = $(this).attr('data-form-id');
    if(t.length)
    {
      t="#" + t;
      $.ajax({
        type: "POST",
        url: $(this).attr('action'),//.replace(/.json$/, '') + '.json',
        data: $(this).serialize(),
        //dataType: 'json',
        success: function (data)
        {       
          $(t).parent().find('.alert').remove();  
          var rhtml = $(data);
        
          if (rhtml.length && rhtml.find('#errorExplanation').length)
          {
            $(t).replaceWith(rhtml);
          }
          else if (rhtml.find('.alert.alert-info').length)
          {
            $(t).replaceWith(rhtml.find('.alert.alert-info').children().remove().end());
            console.log("delayed");
            delayed_reload(3000);
          }
          else
          {
            window.location.reload();
          }
        },
        error: function (data)
        {     
             console.log(data)           ;
          $(t).parent().find('.alert').remove();  
          $(t + ' form').before('<div class="alert alert-danger fade in"><a href="#" data-dismiss="alert" class="close">×</a> ' + data.responseText + '</div>');          
          $(t + ' :input:visible:enabled:first').focus();
        }
      });     
    }
    return false;
  });

});


$(document).ajaxComplete(function(event, request) {
 	popuper(request.getResponseHeader('X-Message'),request.getResponseHeader("X-Message-Type"));    
});
// $(document).ajaxError(function(event, request) {
//   popuper(request.responseText,'error');     
// });

function popuper(msg,msg_type)
{
  var types = {'notice':'alert-info','success':'alert-success','error':'alert-danger','alert':'alert-danger'};
  var type = types[msg_type];
  if (msg && type)
  {
    $('.flash-message').html('<div class="alert '+ type +' fade in">' +
					    '<a href="#" data-dismiss="alert" class="close">×</a>' +
					     urldecode(msg) +
					    '</div>');
    $('.flash-message').find("div.alert").delay(5000).fadeOut(2000,function(){ this.remove();});  	    	  
  }
}

function urldecode(url) {
  return decodeURIComponent(url.replace(/\+/g, ' '));
}

function scrolldown(an,obj)
{  
  var src = $(obj).offset().top + $(obj).height(); 
  an = (typeof an === 'undefined') ? true : an;
  
  if(an)
  {
      $("html,body").stop().animate({
          scrollTop: src
      }, 1000);
  }
  else 
  {
    window.scroll(0,src);
  }
}

var debounce = function (fn) {
  var timeout
  return function () {
    var args = Array.prototype.slice.call(arguments),
        ctx = this

    clearTimeout(timeout)
    timeout = setTimeout(function () {
      fn.apply(ctx, args)
    }, 500)
  }
}  
