/* global $ */
/*eslint no-console: "error"*/
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
//= require jquery.tipsy
//= require jquery.remotipart
//= require jquery.ui.core
//= require jquery.ui.effect
//= require jquery.ui.sortable
////= require jquery.ui.draggable
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
var mob_prev_x = -1;
(function(a){mob=/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))})(navigator.userAgent||navigator.vendor||window.opera);
$(function() {
  $.fn.swipe = function( callback ) {
    var touchDown = false,
      originalPosition = null,
      $el = $( this );

    function swipeInfo( event ) {
      var x = event.originalEvent.pageX,
        y = event.originalEvent.pageY,
        dx, dy;

      dx = ( x > originalPosition.x ) ? "right" : "left";
      dy = ( y > originalPosition.y ) ? "down" : "up";

      return {
        direction: {
          x: dx,
          y: dy
        },
        offset: {
          x: x - originalPosition.x,
          y: originalPosition.y - y
        }
      };
    }

    $el.on( "touchstart", function ( event ) {
      touchDown = true;
      originalPosition = {
        x: event.originalEvent.pageX,
        y: event.originalEvent.pageY
      };
    } );

    $el.on( "touchend", function () {
      touchDown = false;
      originalPosition = null;
    } );

    $el.on( "touchmove", function ( event ) {
      if ( !touchDown ) { return;}
      var info = swipeInfo( event );
      callback( info.direction, info.offset );
    } );

    return true;
  };
});
$(document).ready(function(){


  	// set focus to first text box on page
	if (gon.highlight_first_form_field){
	  $(":input:visible:enabled:first:not(.search-input)").focus();
	}

	// workaround to get logout link in navbar to work
	$('body')
		.off('click.dropdown touchstart.dropdown.data-api', '.dropdown')
		.on('click.dropdown touchstart.dropdown.data-api', '.dropdown form', function (e) { e.stopPropagation() });

  // styled tooltips
  apply_tipsy();


  //for dropdown menu to open on hover

// if(!mob){
//   $(document).on({
//     mouseenter: function () {
//       $(this).closest('.dropdown-menu').stop(true, true).show();
//       $(this).addClass('open');
//     },
//     mouseleave: function () {
//       $(this).closest('.dropdown-menu').stop(true, true).hide();
//       $(this).removeClass('open');
//     }
//   },'ul.nav li.dropdown-hover');

// }
$(".navbar-collapse").swipe(function( direction, offset ) {
  if(direction.x == 'left')
    $('.navbar-toggle').trigger('click');
});

  // $('.navbar-story .navbar-brand').width($('.navbar-story .navbar-toggle').is(':visible') ? $(window).width() - 103 : 'auto');


// $(window).resize(function() {
//     $('.navbar-story .navbar-brand').width($('.navbar-story .navbar-toggle').is(':visible') ? $(window).width() - 103 : 'auto');
// });

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
             //console.log(data)           ;
          $(t).parent().find('.alert').remove();
          $(t + ' form').before('<div class="alert alert-danger fade in"><a href="#" data-dismiss="alert" class="close">×</a> ' + data.responseText + '</div>');
          $(t + ' :input:visible:enabled:first').focus();
        }
      });
    }
    return false;
  });

  $.fn.carousel.defaults = { interval: 5000, pause: 'hover' };
  var carousel = $('.carousel'),
    sticker = carousel.find(".sticker");

  carousel
    .carousel()
    .on('slide.bs.carousel', function (event) {
      sticker.toggle(!event.relatedTarget.hasAttribute("data-is-highlight"));
    });
  if(!carousel.find("[data-is-highlight]").length) { sticker.show(); }

//---------------------------------------------dev stuff-------------------------------------------------
if(gon.dev)
{
  var firstResize = true;
  $(window).resize(function(){
    var t = null;
    if(firstResize)
    {
      t = $("<div class='js-dev-windows-size h'></div>");
      $('body').append(t);
      t.css({"position":"fixed","right":"0px","bottom":"0px", "background-color":"#fff","color":"#000","padding":"6px 10px","font-size":"14px","font-family":"monospace"});
      firstResize = false;
    }
    t = $(document).find('.js-dev-windows-size');
    var w = window.innerWidth;
    var h = window.innerHeight;
    t.html(w+"px / "+h+ "px");
    if(t.hasClass('h'))
    {
      t.toggleClass('h').fadeIn(1000).delay(5000).fadeOut(1000,function(){ t.toggleClass('h'); });
    }
  });
}

// tip
$(document).on("mouseenter", "[data-tip]", function (){
  var t = $(this), tip = $(".tip"),
    content = tip.find(".content").html(t.attr("data-tip")),
    pointer_up = tip.find(".pointer.up"),
    pointer_down = tip.find(".pointer.down"),
    h = tip.height(),
    w = tip.width(),
    bbox = this.getBoundingClientRect();
    if(bbox.top > h + 10) {

      tip.attr("data-pointer", "down");
      tip.css({"top": t.offset().top - h - 10, "left": t.offset().left-w/2+t.width()/2 }).show();
    }
    else {
      tip.attr("data-pointer", "up");
      tip.css({"top": t.offset().top + 30, "left": t.offset().left-w/2+t.width()/2 }).show();
    }
  });
  $(document).on("mouseleave", "[data-tip]", function (){
    $(".tip").hide();
  });

});



$(document).ajaxComplete(function(event, request) {
 	popuper(request.getResponseHeader('X-Message'),request.getResponseHeader("X-Message-Type"));
 	apply_tipsy();
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

// styled tooltips
function apply_tipsy(){
  if ($('form div.help-inline,form div.help-block, form label abbr').length > 0){
    $('form div.help-inline,form div.help-block, form label abbr').tipsy({gravity: 'sw', fade: true});
  }
}

function scrolldown(an,obj)
{
  var src = $(obj).offset().top + $(obj).height() - 54;
  an = (typeof an === 'undefined') ? true : an;

  if(an)
  {
      $("html,body").stop().animate(
      { scrollTop: src },
      {
        duration: 1700,
        easing: 'easeOutExpo'
      });
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



