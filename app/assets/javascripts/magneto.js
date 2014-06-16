var magnetoAnchor = $("header, #wrapper");
var magnetoHeights = [];
var magnetoIndex = 0;

$(document).ready(function(){

  var cp = $(this).scrollTop();  
  magnetoAnchor.each(function(i){
      magnetoHeights[i] = $(this).offset().top;      
  });

  $(document).on('DOMMouseScroll mousewheel', function(e, delta) {

      // do nothing if is already animating
      if($("html,body").is(":animated")) return false;

      // normalize the wheel delta -1 down, 1 up
      delta = delta || -e.originalEvent.detail / 3 || e.originalEvent.wheelDelta / 120;
            
      cp = $(this).scrollTop();  
      magnetoAnchor.each(function(i){    
        if(cp >= magnetoHeights[i]) magnetoIndex = i;           
      }); 

     // increase the anchor magnetoIndex based on wheel direction
     // magnetoIndex = (magnetoIndex-delta) % (magnetoHeights.length);

      // animate the scrolling if scrolling from header to bottom
      if(magnetoIndex == 0 && delta < 0)
      {
        $("html,body").stop().animate({
            scrollTop: magnetoHeights[1]
        }, 1000);
        e.preventDefault();        
      }
  });
});



    var scrollOffset = 0;
       var isNavVisible = false;
       var objectOffset = $("#filter").offset().top;
       var topOffsetBack = 150;

       function navbarMagic(reset)
       {                            
          reset = typeof reset !== 'undefined' ?  reset : false;
          var currentOffset = $(window).scrollTop();
                                    
          if(reset)
          {                                              
                isNavVisible = !(currentOffset <= objectOffset-topOffsetBack);      
                if(isNavVisible)
                {
                  //console.log("reset make visible");       
                  $(".navbar").removeClass("navbar-invisible"); 
                  $(".navbar").addClass("navbar-visible");      
                }
                else          
                {                 
                  //console.log("reset make invisible");     
                  $(".navbar").removeClass("navbar-visible"); 
                  $(".navbar").addClass("navbar-invisible");      
                }   
                scrollOffset = currentOffset;
                $(window).on('scroll',function(){navbarMagic(); });

          }
          else
          {
            if(scrollOffset < currentOffset)
            {         
              //console.log("down");
              if(!isNavVisible && currentOffset >= objectOffset-topOffsetBack)
              {
                  //console.log("make visible"); 
                  $(".navbar").removeClass("navbar-invisible");                                     
                  $(".navbar").addClass("navbar-visible");                
                  isNavVisible = true;
              }         
            }
            else 
            {
              //console.log("up");
              if(isNavVisible && currentOffset <= objectOffset - topOffsetBack)
              {      
                  //console.log("make invisible"); 
                  $(".navbar").removeClass("navbar-visible");                                     
                  $(".navbar").addClass("navbar-invisible");   
                  isNavVisible = false;                   
              }
            }
          }
          scrollOffset = currentOffset;
       }
