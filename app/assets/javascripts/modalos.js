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
		    margins: 40,
		    paddings: 20,
		    fullscreen: false,
		    aspectratio: false,
		    width:'962',
		    height: 'auto',
		    //621px'
    	}; 
    	
        //Extend dem' options
        var options = $.extend({}, defaults, options); 
        return this.each(function() {
        console.log('herer modalos');
/*---------------------------
 Global Variables
----------------------------*/

        	var modal = $(this),
        		wrapper = $('.modalos-wrapper'), 
          		bg = $('.modalos-bg'), 
          		keeper = $('.modalos-keeper'), 
          		locked = false,
          		header_height = 15,
          		content = null
          	 				
/*---------------------------
 Create Modal Wrapper and Bg if not exists
----------------------------*/
			if(wrapper.length == 0) {
				wrapper = $("<div class='modalos-wrapper'> \
	      								<div class='m-header'> \
	      									<div class='m-close'> \
	      										<img src='/assets/svg/close.svg'> \
	      									</div> \
	      								</div> \
      									<div class='m-content'>	\
	      								</div> \
								</div>").appendTo('body');		

			}	
			if(bg.length == 0) {
				bg = $('<div class="modalos-bg" />').appendTo('body');
			}
     		content = wrapper.find('.m-content').css("padding",options.paddings);

/*---------------------------
 Open & Close Animations
----------------------------*/
			//Entrance Animations
			modal.bind('modalos:open', function () {
				var opened = false;
			
			    if (options.before_open) options.before_open(this);
			  	bg.unbind('click.modalEvent');
				$('.m-close').unbind('click.modalEvent');

				if(!locked) {
					lock();
				 	lock_scroll();
					render();				
				     modal.detach();

				     if(options.contentscroll)
				     	content.css("overflow-x","hidden").css("overflow-y","auto");
				     else content.css("overflow","hidden");

					content.html($(modal).css("display","block"));
			 				
					if(options.animation == "fade" && !opened) {

		         	 	wrapper.css({'opacity' : 0, 'display' : 'block'});						
						bg.fadeIn(options.animationspeed/2);
						wrapper.delay(options.animationspeed/2).animate({
							"opacity" : 1
						}, options.animationspeed,unlock());				
					} 
					else { //(options.animation == "none") 
					 	wrapper.css("display","block");
			         	bg.css("display","block");		    						
						unlock();				
					}
				}
				modal.unbind('modalos:open');
				if (options.after_open) options.after_open();
			}); 	

			//Closing Animation
			modal.bind('modalos:close', function () {

				if (options.before_close) options.before_close(this);
			  if(!locked) {
					lock();
					unlock_scroll();
					if(options.animation == "fade") {    
						bg.delay(options.animationspeed).fadeOut(options.animationspeed);
						wrapper.animate({
							"opacity" : 0
						}, options.animationspeed, function() {
							wrapper.css({'opacity' : 1, 'display' : 'none'});
							unlock();
						});					
					}  	
					if(options.animation == "none") {
						wrapper.css({'display' : 'none'});
						bg.css({'display' : 'none'});	
					}			
				}

				modal.unbind('modalos:resize');
				modal.unbind('modalos:close');
				content.empty();

			});     

   			modal.bind('modalos:resize', function () {	
				render();		  
			});     
/*---------------------------
 Open and add Closing Listeners
----------------------------*/
        	//Open Modal Immediately
    		modal.trigger('modalos:open');
			var closeButton = $('.m-close').bind('click.modalEvent', function () {
			  modal.trigger('modalos:close')
			});
			
			if(options.closeonbackgroundclick) {
				bg.css({"cursor":"pointer"})
				bg.bind('click.modalEvent', function () {
				  modal.trigger('modalos:close')
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
				if(options.lockscroll) $('body').css("overflow","hidden");				
			}
			function unlock_scroll() {
				if(options.lockscroll) $('body').css("overflow","visible");			
			}
			function render()
			{				
		 		var h = $(window).height();
		 		var w = $(window).width();
			      	 
	      	 if(options.fullscreen)
		    	 {
		    	 	$(wrapper).height(h - options.topOffset - options.margins);
		    	 	$(wrapper).find('.m-content').css("max-height",h - options.topOffset - options.margins - header_height).removeClass("fluid");
		    	 	if(options.aspectratio)
		    	 	{		    	 		
    	 				$(wrapper).width(aspect_ratio_width(h,w,$(wrapper).height())); 
    	 				$(wrapper).css("left", (w - $(wrapper).width())/2);	
		    	 	}
	    	 		else 
    	 			{
    	 				$(wrapper).width(w - options.margins); 
				     	$(wrapper).css("left",options.margins/2);	
			     	}

	 		        $(wrapper).css("top",options.margins/2 + options.topOffset);				    	
	    	 	 }
		    	 else
		    	 {		  
    	 		 	var fill = options.width > w ? true : false;  
		    	 	
		    	 	$(wrapper).find('.m-content').css("max-height", fill ? h : h - options.topOffset - options.margins - header_height).addClass("fluid");
		    	 	if(fill) 
	    	 		{	    		    	 		
	    	 			$(wrapper).width(w).height(h);
	    	 		}
			    	else 
		    		{		    			    	 		
		    			// console.log(options)
		    			$(wrapper).width(options.width-options.margins);
		    			if(options.height + options.topOffset > h)
			    	 	{
		    	 			$(wrapper).height(h - options.topOffset - options.margins);
			    	 	}
			    	 	else
			    	 			$(wrapper).height(options.height);

		    		}
		    	
		    	 	$(wrapper).css("top",fill ? 0 : ((h- options.height)/2 > options.topOffset ? (h- options.height)/2 : options.topOffset));
			     	$(wrapper).css("left",fill ? 0 : (w - options.width)/2);		 
		    	 }
			}
			function aspect_ratio_width(oh,ow,h)
			{
				return Math.ceil(ow*h/oh);
			}
     	});//each call			

    }
})(jQuery);
        


