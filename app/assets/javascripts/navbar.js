$(document).ready(function() {  
    navbarMagic(true); 
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
          $(".navbar").removeClass("navbar-invisible").addClass("navbar-visible-invisible").delay(13).queue(function(){
              $(this).toggleClass("navbar-visible navbar-visible-invisible").dequeue();
          });      
        }
        else          
        {                 
          //console.log("reset make invisible");     
          $(".navbar").removeClass("navbar-visible").addClass("navbar-invisible");          
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
          $(".navbar").removeClass("navbar-invisible").addClass("navbar-visible-invisible").delay(13).queue(function(){
              $(this).toggleClass("navbar-visible navbar-visible-invisible").dequeue();
          });                                                                   
          isNavVisible = true;
      }         
    }
    else 
    {
      //console.log("up");
      if(isNavVisible && currentOffset <= objectOffset - topOffsetBack)
      {      
          //console.log("make invisible"); 
          $(".navbar").removeClass("navbar-visible").addClass("navbar-invisible");                                                 
          isNavVisible = false;                   
      }
    }
  }
  scrollOffset = currentOffset;
}
