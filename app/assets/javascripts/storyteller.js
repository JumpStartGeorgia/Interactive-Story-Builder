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
     var lastScroll = 0;
     var sn = true;
     var sbn = true;
      $(window).scroll(function(event){
          //Sets the current scroll position
          var st = $(this).scrollTop();
          var sbh = $(".navbar-storybuilder").height();
          //Determines up-or-down scrolling
          if (st > lastScroll){ //down
             if(sbn)
             {
                $(".navbar-storybuilder").animate({top:-1*sbh},300);
                $(".navbar-story").animate({top:'0px'}, 300);
            sbn = false;
            }
          }
          else {//up             
                  if(!sbn)
                  {                    
                    $(".navbar-storybuilder").animate({top:'0px'},300);
                    $(".navbar-story").animate({top:sbh}, 300);
                    sbn = true;                
                  }
          }
          //Updates scroll position
          lastScroll = st;
      });
//#modalAbout, 
       $('#modalAbout').on('click', function(e) {        
        var ml = $(this).attr('data-modalos-id');   
        var v = $('.navbar-story');      
        $('#'+ml).modalos({topOffset: $(v).position().top + $(v).height() + 30});
        e.preventDefault();
      }); 
      $('#modalComment').on('click', function(e) {        
        var ml = $(this).attr('data-modalos-id');  
        var v = $('.navbar-story');      
        $('#'+ml).modalos({topOffset: $(v).position().top + $(v).height() + 30});
        e.preventDefault();
      }); 
      $('#modalShare').on('click', function(e) {        
        var ml = $(this).attr('data-modalos-id');  
        var v = $('.navbar-story');      
        $('#'+ml).modalos({topOffset: $(v).position().top + $(v).height() + 30, width:672, height:575,lockscroll:true});
        e.preventDefault();
      }); 


      $('.iframe-size').change(function(){
        var iframe_width=$(this).val();
        var frame_code = $('.embed-code textarea');
       
        frame_code .text("<iframe src='" +  frame_code.attr('data-iframe-link') + "?width="+iframe_width+"' width='"+iframe_width+"' height='100%' frameborder='0'></iframe>");
      });
  });