
       var scrollOffset = 0;
       var isNavVisible = true;
       function navbarMagic(reset)
       {      
        console.log("isNavVisible = " + isNavVisible);
            console.log($(window).scrollTop());
            reset = typeof reset !== 'undefined' ?  reset : false;
            var currentOffset = $(window).scrollTop();
            var objectOffset = $("#filter").offset().top;
            var topOffsetBack = 150;
            //console.log("Offset from top: "+$(this).scrollTop());            
            //down
          if(reset)
          {
            if(scrollOffset <= objectOffset-topOffsetBack)
            {
              if( isNavVisible)
              {
              console.log("invisible_");
                 isNavVisible = false; 
              $(".navbar").queue(function(){
                    $(this).fadeOut(400,function(){
                      $(this).css("background-color","rgba(255,255,255,0.0)")
                      $(this).css("position","absolute");
                      $(this).css("top","30px");                                            
                    }).fadeIn(10).dequeue();   
                    //animate({}, 1000,function(){ }).dequeue();                   
                    
                 });
              }
            }
            else
            {        
             if( !isNavVisible)
              { 
                console.log("visible_");       
                $(".navbar").css("position","fixed").css("top","0px").queue(function(){
                  $(this).animate({"background-color":"#121212"}, 1000).dequeue();
                }); 
                isNavVisible = true;
              }
            }
          }
          else
          {
            if(scrollOffset < currentOffset)
            {         

              console.log("down");
              if(!isNavVisible && currentOffset >= objectOffset-topOffsetBack)
              {
                console.log("navbar visible");
               // $(".navbar").toggleClass("navbar-static-top navbar-fixed-top").css("background-color","#000");                
                 $(".navbar").css("position","fixed").css("top","0px").queue(function(){
                    $(this).animate({"background-color":"#121212"}, 1000).dequeue();
                  }); 
                  isNavVisible = true;
              }
         
            }
            else 
            {
              console.log("up" + currentOffset + " _ " + objectOffset );
              if(isNavVisible && currentOffset <= objectOffset - topOffsetBack)
              {      
                  isNavVisible = false;          
                console.log("navbar invisible");
               // $(".navbar").toggleClass("navbar-static-top navbar-fixed-top").css("background-color","transparent");
                //$(".navbar").css("background-color","transparent").css("position","absolute");
                 $(".navbar").queue(function(){
                    $(this).fadeOut(400,function(){
                      $(this).css("background-color","rgba(255,255,255,0.0)")
                      $(this).css("position","absolute");
                      $(this).css("top","30px");                                            
                    }).fadeIn(10).dequeue();   
                    //animate({}, 1000,function(){ }).dequeue();                   
                    
                 });
              }
            }
          }
            scrollOffset = currentOffset;
       }
      $(document).ready(function() {  
          var sa = false;
          var sl = true;
          $('.search-box input').show();

          $('.search-box input').focusout(function(){
            if($(this).val().length==0)
            {
              $(".search-box").removeClass("active");
             //   $(".search-box input").hide();
              $(".search-label").show();                     
              sa = false;
              sl = true;     
            }
      
          });
           $('.search-box').hover(function()
           {        
              if(!sa)
              {
                 $(".search-box").addClass("active");  
               //  $(".search-box input").show();
                 sa = true; 
                 sl = false;     
                 $(".search-label").hide();
              }
           },
           function(){
            if($(this).find("input").val().length==0 && sa)
          {
                $(this).find("input").trigger("blur");
                 $(".search-box").removeClass("active");  
                // $(".search-box input").hide();
                 sa = false; 
                 $(".search-label").show();                
                 sl = true;     
              }
           });


          $(".search-button").click(function(){ console.log("ajax search");});
        
          scrollOffset = $(window).scrollTop();      
          navbarMagic(true);
          $(window).on('scroll',function(){navbarMagic(); });
      
      });
