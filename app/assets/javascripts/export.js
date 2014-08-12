$(document).ready(function(){
          $('#modalAbout').on('click', function(e) {        
        var ml = $(this).attr('data-modalos-id');   
        var v = $('.navbar-story');      
        $('#'+ml).modalos({topOffset: $(v).position().top + $(v).height() + 30, width:672});
        e.preventDefault();
      }); 
      $('#modalShare').on('click', function(e) {        
        var ml = $(this).attr('data-modalos-id');  
        var v = $('.navbar-story');      
        $('#'+ml).modalos({topOffset: $(v).position().top + $(v).height() + 30, width:672, height:575});
        e.preventDefault();
      }); 


      $('.iframe-size').change(function(){
        var iframe_width=$(this).val();
        var frame_code = $('.embed-code textarea');
       
        frame_code .text("<iframe src='" +  frame_code.attr('data-iframe-link') + "?width="+iframe_width+"' width='"+iframe_width+"' height='100%' frameborder='0'></iframe>");
      });
      $('.navigation-icon').trigger( "click" );
  });