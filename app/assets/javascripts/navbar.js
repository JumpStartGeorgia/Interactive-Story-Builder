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
          console.log("reset make visible");       
          $(".navbar").removeClass("navbar-invisible"); 
          $(".navbar").addClass("navbar-visible");      
        }
        else          
        {                 
          console.log("reset make invisible");     
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
