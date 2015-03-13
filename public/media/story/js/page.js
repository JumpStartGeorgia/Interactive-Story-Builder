$(document).ready(function(){
   $('.section.infographic .container .content.infographic').click(function(){
     var t = $(this);
     var image =  $('<img>',
     {
         on: 
         {
           load: function() { 
             console.log(this.width);
             image.modalos({topOffset: 30, leftOffset: 30, width: this.width, height: this.height, paddings:0, margins:0, klass:'infographic', dragscroll:true });
             
           },
           error: function(e) { 
             console.log(this,' - not loaded'); 
           }
         },
         "src":t.attr('data-original')
     });
    
   });
   $('.section.infographic .container .content.interactive').click(function(){
     $($(this).find('.interactive-iframe-popup').html()).modalos({topOffset: 50, leftOffset: 0, fullscreen: true, paddings:0, margins:30, klass:'interactive', dragscroll:true });
   });
});
