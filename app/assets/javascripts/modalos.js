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
	var curModalos = null;
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
        
/*---------------------------
 Global Variables
----------------------------*/

        	var modal = $(this),
        		wrapper = $('.modalos-wrapper'), 
          		bg = $('.modalos-bg'), 
          		keeper = $('.modalos-keeper'), 
          		locked = false,
          		header_height = 15
          	 				
/*---------------------------
 Create Modal Wrapper and Bg if not exists
----------------------------*/
			if(wrapper.length == 0) {
				wrapper = $("<div class='modalos-wrapper'> \
	      								<div class='m-header'> \
	      									<div class='m-close'> \
	      										<img src='/assets/close_h.png' style='width: 33px;height: 33px;'> \
	      									</div> \
	      								</div> \
      									<div class='m-content'>	\
	      								</div> \
								</div>").appendTo('body');			
			}	
			if(bg.length == 0) {
				bg = $('<div class="modalos-bg" />').appendTo('body');
			}
			if(keeper.length == 0) {
				keeper = $('<div class="modalos-keeper"/>').appendTo('body');
			}	 	    
     		wrapper.find('.m-content').css("padding",options.paddings);
/*---------------------------
 Open & Close Animations
----------------------------*/
			//Entrance Animations
			modal.bind('modalos:open', function () {
				var opened = false;
				if(curModalos!=null)
				{
					keeper.append(curModalos);
					opened = true;
				}				
				curModalos = modal;
				//console.log("modalos:open");
				//console.log(options.topOffset);
			    if (options.before_open) options.before_open(this);

			  	bg.unbind('click.modalEvent');
				$('.m-close').unbind('click.modalEvent');

				if(!locked) {
					lock();
				 	lock_scroll();
					render();				
				     modal.detach();
				     var content =  $(wrapper).find('.m-content');

				     if(options.contentscroll)
				     	content.css("overflow-x","hidden").css("overflow-y","auto");
				     else content.css("overflow","hidden");

					content.html($(modal).css("display","block"));
			 
					// if(options.animation == "fadeAndPop") {

					// 	modal.css({'top': $(document).scrollTop()-topOffset, 'opacity' : 0, 'display' : 'block'});
					// 	modalBG.fadeIn(options.animationspeed/2);
					// 	modal.delay(options.animationspeed/2).animate({
					// 		"top": $(document).scrollTop()+topMeasure + 'px',
					// 		"opacity" : 1
					// 	}, options.animationspeed,unlockModal());			
					// }
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

				//console.log('modalos:close');
				if (options.before_close) options.before_close(this);
				keeper.append(modal);
				curModalos = null;
			  if(!locked) {
					lock();
					unlock_scroll();

					// if(options.animation == "fadeAndPop") {
					// 	//modalBG.delay(options.animationspeed).fadeOut(options.animationspeed);
					// 	modal.animate({
					// 		"top":  $(document).scrollTop()-topOffset + 'px',
					// 		"opacity" : 0
					// 	}, options.animationspeed/2, function() {
					// 		modal.css({'top':topMeasure, 'opacity' : 1, 'display' : 'none'});
					// 		unlock();
					// 	});					
					// }  	
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
			});     

   			modal.bind('modalos:resize', function () {	
   				render();
		      // 	 $(wrapper).height($(window).height() - options.topOffset - options.margins);
		    	 // $(wrapper).width($(window).width() - options.margins);
			     // $(wrapper).css("top",options.margins/2 + options.topOffset);
			     // $(wrapper).css("left",options.margins/2);		         

				 //modal.css({'left': ($(window).width()-modal.outerWidth(true))/2 + 'px'});						
			});     
/*---------------------------
 Open and add Closing Listeners
----------------------------*/
        	//Open Modal Immediately
    		modal.trigger('modalos:open');
			//console.log("listeners");
			//Close Modal Listeners
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
		    	 	$(wrapper).height(options.height);
		    	 	$(wrapper).find('.m-content').css("max-height",h - options.topOffset - options.margins - header_height).addClass("fluid");
		    	 	if(options.width > w) 
	    	 		{
	    	 			options.width = w-options.margins;
	    	 			$(wrapper).width(options.width);
	    	 		}
			    	else $(wrapper).width(options.width);
		    	 	if(options.height + options.topOffset > h)
		    	 	{
	    	 			$(wrapper).height(h - options.topOffset - options.margins);
		    	 	}
		    	 	$(wrapper).css("top",(h- options.height)/2 > options.topOffset ? (h- options.height)/2 : options.topOffset);
			     	$(wrapper).css("left",(w - options.width)/2);		 
		    	 }
			}
			function aspect_ratio_width(oh,ow,h)
			{
				return Math.ceil(ow*h/oh);
			}
				
			
        	});//each call			

    }
})(jQuery);
        


