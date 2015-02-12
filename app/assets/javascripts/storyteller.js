// record that a comment was made
// - this is called from storyteller/index file which is where the disqus code is located
function story_new_comment_callback(url){
  console.log('deprecated');
  // $.ajax
  // ({
  //   url: url + '/record_comment',
  //   dataType: 'json'
  // }).done(function(d) { 
  //   // update the comment count on the page
  //   $('#comments-count').html(d.count);
  // });
}

$(document).ready(function() {

    // staff pick
    // $('a.staff-pick').click(function(e){
    //   var ths = this;
  		// e.preventDefault();		
	   //  $.ajax
	   //  ({
		  //   url: $(this).data('href'),
    //     dataType: 'json'
	   //  }).done(function(d) { 
    //     if ($(ths).hasClass('hide')){
    //       $('a.staff-pick').addClass('hide');
    //       $(ths).removeClass('hide');
    //     }else {
    //       $('a.staff-pick').addClass('hide');
    //       $('a.staff-pick').each(function(e){
    //         if (this != ths){
    //           $(this).removeClass('hide');
    //         }
    //       });        
    //     }
	   //  });
    // });


    // // like
    // $('a.like-story').click(function(e){
    //   var ths = this;
  		// e.preventDefault();		
	   //  $.ajax
	   //  ({
		  //   url: $(this).data('href'),
    //     dataType: 'json'
	   //  }).done(function(d) { 
    //     if ($(ths).hasClass('hide')){
    //       $('a.like-story').addClass('hide');
    //       $(ths).removeClass('hide');
    //     }else {
    //       $('a.like-story').addClass('hide');
    //       $('a.like-story').each(function(e){
    //         if (this != ths){
    //           $(this).removeClass('hide');
    //         }
    //       });        
    //     }
	   //  });
    // });
});



$(document).ready(function(){
    if($(".navbar-storybuilder").length != 0)
    {
      //$(".navbar-story").css("top","54px");
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
                //$(".navbar-story").animate({top:'0px'}, 300);
            sbn = false;
            }
          }
          else {//up             
                  if(!sbn)
                  {                    
                    $(".navbar-storybuilder").animate({top:'0px'},300);
                    //$(".navbar-story").animate({top:sbh}, 300);
                    sbn = true;                
                  }
          }
          //Updates scroll position
          lastScroll = st;
      });
    }

      $('.section.infographic .container .content').click(function(){
        var t = $(this);
        //var ml =  $('<div id="modalos-infographic"></div>');
        var image =  $('<img>',
        {
            on: 
            {
              load: function() { 
                console.log(this.width);
                 var v = $('.navbar-storybuilder');   
                image.modalos({topOffset: v.position().top + v.height() + 30, leftOffset: 30, width: this.width, height: this.height, paddings:0, margins:0, klass:'infographic', dragscroll:true });
                
              },
              error: function(e) { 
                console.log(this,' - not loaded'); 
              }
            },
            "src":t.attr('data-original')
        });
       
      });


      $('.modalEmbed').on('click', function(e) {      
        var v = $('.navbar-storybuilder');   
        $($('#modalos-embed').get(0).outerHTML).modalos({topOffset: v.position().top + v.height() + 30, width:350, height:370});
        e.preventDefault();
      });     

      $(document).on('click','.embed-type-switcher > div',function(){        
        $('.embed-type-switcher > div').each(function(){$(this).toggleClass('selected');}); 
        var frame_code = $('.embed-code textarea');
        var iframe_width= $(this).data('width');
        var embed_type = 'partial';
        if($(this).hasClass('full')) 
        {                    
          embed_type = 'full';
        }        
        frame_code.text("<iframe src='" +  frame_code.attr('data-iframe-link') + "?type="+embed_type+"' width='"+iframe_width+"' height='100%' frameborder='0'></iframe>");
        $('.iframe-size').val(iframe_width);
      });

      $(document).on('change', '.iframe-size', function(){
        var iframe_width=$(this).val();
        var frame_code = $('.embed-code textarea'); 
        var embed_type = 'partial';
        
        if($('.embed-type-switcher > div.selected').hasClass('full')) 
        {                    
          embed_type = 'full';
        }        
        frame_code.text("<iframe src='" +  frame_code.attr('data-iframe-link') + "?type="+embed_type+"' width='"+iframe_width+"' height='100%' frameborder='0'></iframe>");
      });
  });
