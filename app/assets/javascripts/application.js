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
$(document).ready(function(){
	// set focus to first text box on page
	if (gon.highlight_first_form_field){
	  $(":input:visible:enabled:first:not(.search-input)").focus();
	}

	// workaround to get logout link in navbar to work
	$('body')
		.off('click.dropdown touchstart.dropdown.data-api', '.dropdown')
		.on('click.dropdown touchstart.dropdown.data-api', '.dropdown form', function (e) { e.stopPropagation() });

  $('ul.nav li.dropdown-hover').hover(function(){ 
      $(this).closest('.dropdown-menu').stop(true, true).show();
      $(this).addClass('open'); 
    },
    function(){
      $(this).closest('.dropdown-menu').stop(true, true).hide();
      $(this).removeClass('open'); 
  });

  // fancy select boxes with search capability
  if ($('.selectpicker').length > 0){
    $('.selectpicker').selectpicker({dropupAuto:false});
  }

  $('#modalSignIn').on('click', function(e) {        
      var ml = $(this).attr('data-modalos-id');   
      var v = $('.navbar-story').length ? $('.navbar-story') : $('.navbar-storybuilder');      
      $('#'+ml).modalos({topOffset: $(v).position().top + $(v).height() + 30, width:435});
      e.preventDefault();
  });

});


$(document).ajaxComplete(function(event, request) {
 	popuper(request.getResponseHeader('X-Message'),request.getResponseHeader("X-Message-Type"));  
});

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
