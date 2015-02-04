$(document).ready(function(){
          
      $('#modalEmbed').on('click', function(e) {        
        var ml = $(this).attr('data-modalos-id');  
        var v = $('.navbar-storybuilder');      
        $('#'+ml).modalos({topOffset: $(v).position().top + $(v).height() + 30, width:672, height:400});
        e.preventDefault();
      }); 

      $('.iframe-size').change(function(){
        var iframe_width=$(this).val();
        var frame_code = $('.embed-code textarea');
       
        frame_code .text("<iframe src='" +  frame_code.attr('data-iframe-link') + "?width="+iframe_width+"' width='"+iframe_width+"' height='100%' frameborder='0'></iframe>");
      });
      $('.navigation-volume').trigger( "click" );
  });