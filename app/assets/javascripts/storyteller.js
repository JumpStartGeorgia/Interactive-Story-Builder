// record that a comment was made
// - this is called from storyteller/index file which is where the disqus code is located
function story_new_comment_callback(url){
  $.ajax
  ({
    url: url + '/record_comment',
    dataType: 'json'
  }).done(function(d) { 
    // update the comment count on the page
    $('#comments-count').html(d.count);
  });
}

$(document).ready(function() {

    // staff pick
    $('#story-header-buttons a.staff-pick').click(function(e){
      var ths = this;
  		e.preventDefault();		
	    $.ajax
	    ({
		    url: $(this).data('href'),
        dataType: 'json'
	    }).done(function(d) { 
        if ($(ths).hasClass('hide')){
          $('#story-header-buttons a.staff-pick').addClass('hide');
          $(ths).removeClass('hide');
        }else {
          $('#story-header-buttons a.staff-pick').addClass('hide');
          $('#story-header-buttons a.staff-pick').each(function(e){
            if (this != ths){
              $(this).removeClass('hide');
            }
          });        
        }
	    });
    });


    // like
    $('#story-header-buttons a.like-story').click(function(e){
      var ths = this;
  		e.preventDefault();		
	    $.ajax
	    ({
		    url: $(this).data('href'),
        dataType: 'json'
	    }).done(function(d) { 
        if ($(ths).hasClass('hide')){
          $('#story-header-buttons a.like-story').addClass('hide');
          $(ths).removeClass('hide');
        }else {
          $('#story-header-buttons a.like-story').addClass('hide');
          $('#story-header-buttons a.like-story').each(function(e){
            if (this != ths){
              $(this).removeClass('hide');
            }
          });        
        }
	    });
    });




});




$(document).ready(function(){
  var info = false;

  var currentScroll=0;
  var infoOffset = 40;
  $('.story-menu, .story-info-close').click(function()
  {   
    
    if(info)
    {
      $('body').css("overflow","visible");
      $('.story-info-wrapper').fadeOut();
    }
        else
        {

      $('body').css("overflow","hidden");
      $('.story-info-wrapper').height($(window).height() - 60 - infoOffset);
    $('.story-info-wrapper').width($(window).width() - infoOffset);
    $('.story-info-wrapper').css("top",infoOffset/2 + 60);
    $('.story-info-wrapper').css("left",infoOffset/2);
      $('.story-info-wrapper').fadeIn();
    }
    info=!info;

  });

    $( window ).resize(function() {
     if(info)
    {
        
        $('.story-info-wrapper').height($(window).height() - 60 - infoOffset);
        $('.story-info-wrapper').width($(window).width() - infoOffset);
        $('.story-info-wrapper').css("top",infoOffset/2 + 60);
        $('.story-info-wrapper').css("left",infoOffset/2);        
      }


    });




  });
