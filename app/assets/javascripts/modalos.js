/*
 * jQuery Modalos Plugin 1.0
 * www.jumpstart.ge
 * Copyright 2014, Jumpstart
*/


(function($) {

/*---------------------------
 Defaults for Modulos
----------------------------*/
	 
/*---------------------------
 Listener for data-modalos-id attributes
----------------------------*/
	

/*---------------------------
 Extend and Execute
----------------------------*/
    $.fn.modalos = function(options) {
        
        var defaults = {  
	    	animation: 'fade', //fade, fadeAndPop, none
		    animationspeed: 300, //how fast animtions are
		    closeonbackgroundclick: true, //if you click background will modal close?		    
		    lockscroll: false, // body scroll will be locked, with css overflow hidden
		    contentscroll: true, // m-content box is srollable or not, for iframe use false value
		    before_open: null,
		    after_open: null,
		    before_close: null, 
		    after_close: null,
		    topOffset: 60,
		    leftOffset: 30,
		    margins: 40,
		    paddings: 20,
		    fullscreen: false,
		    aspectratio: false,
		    width:'962',
		    height: 'auto',
		    klass: '',
		    dragscroll: false
		    //621px'
    	}; 
    	
        //Extend dem' options
        var options = $.extend({}, defaults, options); 
        return this.each(function() {
/*---------------------------
 Global Variables
----------------------------*/

        	var modal = $(this),
        		wrapper = $('.modalos-wrapper'), 
          		//bg = $('.modalos-bg'), 
          		keeper = $('.modalos-keeper'), 
          		locked = false,
          		header_height = 15,
          		content = null,
          		box = null;
          	 				
/*---------------------------
 Create Modal Wrapper and Bg if not exists
----------------------------*/
			//if(wrapper.length == 0) {
				wrapper = $("<div class='modalos-wrapper'> \
										<div class='m-box'> \
											<div class='m-close'></div> \
      									<div class='m-content'></div> \
      								</div> \
								</div>").appendTo('body');
				if(options.dragscroll) {
					wrapper.dragScroll({});
				}						
			//}	
			wrapper.removeClass().addClass('modalos-wrapper ' + options.klass);
			//if(bg.length == 0) {
		//		bg = $('<div class="modalos-bg" />').appendTo('body');
		//	}
     		content = wrapper.find('.m-content');
     		box = wrapper.find('.m-box').css("padding",options.paddings);

/*---------------------------
 Open & Close Animations
----------------------------*/
			//Entrance Animations
			modal.bind('modalos:open', function () {
				var opened = false;
			
			   if (options.before_open) options.before_open(this);

			  	wrapper.off('click');
				$('.m-close').off('click');

				if(!locked) {
					lock();
					render();				
				   modal.detach();

			    	wrapper.css({'overflow-x':'auto','overflow-y':'scroll'});	 
					content.html($(modal).css("display","block"));
			 				
					if(options.animation == "fade" && !opened) {
						wrapper.fadeIn(options.animationspeed,unlock());
					} 
					else 
					{
					 	wrapper.show();
						unlock();				
					}
				}
				modal.off('modalos:open');
				if (options.after_open) options.after_open();
			}); 	

			//Closing Animation
			modal.bind('modalos:close', function () {
					$('body').css('overflow','initial');
					wrapper.css('overflow','hidden');

				if (options.before_close) options.before_close(this);
			  if(!locked) {
					lock();
					if(options.animation == "fade") {    
						wrapper.fadeOut(options.animationspeed,unlock());
					}  	
					if(options.animation == "none") {
						wrapper.hide();
					}			
				}

				modal.unbind('modalos:resize');
				modal.unbind('modalos:close');
				wrapper.remove();

			});     

			modal.bind('modalos:resize', function () {	
				render();		  
			});     
/*---------------------------
 Open and add Closing Listeners
----------------------------*/
        	//Open Modal Immediately
    		modal.trigger('modalos:open');
			var closeButton = $('.m-close').on('click', function () {
			  modal.trigger('modalos:close')
			});
			
			if(options.closeonbackgroundclick) {
				wrapper.css({"cursor":"pointer"}).on('click', function (e) {
					if(e.target == e.currentTarget)
				  		modal.trigger('modalos:close');
				});
			}
			$('body').keyup(function(e) {
        		if(e.which===27){ modal.trigger('modalos:close'); } // 27 is the keycode for the Escape key
			});

			$(window).resize(function() {
        		modal.trigger('modalos:resize'); 
			});			
			
/*---------------------------
 Animations Locks
----------------------------*/
			function unlock() { 
				locked = false;	
			}
			function lock() {
				locked = true;				
			}
			function lock_scroll() {
				//if(options.lockscroll) $('body').css("overflow","hidden");				
			}
			function unlock_scroll() {
				//if(options.lockscroll) $('body').css("overflow","visible");			
			}
			function render()
			{				
		 		var h = $(window).height();
		 		var w = $(window).width();
			      	 
	      	 if(options.fullscreen)
		    	 {
		    	 	$(box).height(h - options.topOffset - options.margins);
		    	 	$(box).find('.m-content').css("max-height",h - options.topOffset - options.margins - header_height).removeClass("fluid");
		    	 	if(options.aspectratio)
		    	 	{		    	 		
    	 				$(box).width(aspect_ratio_width(h,w,$(box).height())); 
    	 				$(box).css("left", (w - $(box).width())/2);	
		    	 	}
	    	 		else 
    	 			{
    	 				$(box).width(w - options.margins); 
				     	$(box).css("left",options.margins/2);	
			     	}

	 		        $(box).css("top",options.margins/2 + options.topOffset);				    	
	    	 	 }
		    	 else
		    	 {		  
    	 		 	var wOut = options.width > w ? true : false;  
    	 		 	var hOut = options.height > h ? true : false;  
		    	 		    	 
			    	if(!wOut) 
		    		{		    			    	 		
		    			$(box).width(options.width+options.margins);
		    			if(options.height + options.topOffset > h) $(box).height(h - options.topOffset - options.margins);
			    	 	else $(box).height(options.height);
		    		}
		    	 	$(box).css("top", hOut ? options.topOffset : ((h- options.height)/2 > options.topOffset ? (h- options.height)/2 : options.topOffset));
			     	$(box).css("left",wOut ? options.leftOffset : ((w- options.width)/2 > options.leftOffset ? (w- options.width)/2 : options.leftOffset));
			     	$('body').css('overflow','hidden');	 
		    	 }
			}
			function aspect_ratio_width(oh,ow,h)
			{
				return Math.ceil(ow*h/oh);
			}
     	});//each call			

    }
})(jQuery);
      



/* 
	DraggScroll is a JQuery extension for scrolling by clicking and dragging from within a container.
	Author: James Climer (http://climers.com)
	Released under the Apache V2 License: http://www.apache.org/licenses/LICENSE-2.0.html
	Requires JQuery: http://jquery.com	
	Get latest version from: https://github.com/jaclimer/JQuery-DraggScroll
	
    options: Currently not used
*/
(function ($) {
    $.fn.dragScroll = function (options) {
        /* Mouse dragg scroll */
        var x, y, top, left, down;
        var t = $(this);

        t.attr("onselectstart", "return false;");   // Disable text selection in IE8

        t.mousedown(function (e) {
            e.preventDefault();
            down = true;
            x = e.pageX;
            y = e.pageY;
            top = $(this).scrollTop();
            left = $(this).scrollLeft();
        });
        t.mouseleave(function (e) {
            down = false;
        });
        $("body").mousemove(function (e) {
            if (down) {
                var newX = e.pageX;
                var newY = e.pageY;
                t.scrollTop(top - newY + y);
                t.scrollLeft(left - newX + x);
            }
        });
        $("body").mouseup(function (e) { down = false; });
    };
})(jQuery);

