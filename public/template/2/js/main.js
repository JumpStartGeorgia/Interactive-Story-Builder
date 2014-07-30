$('#modalAboutProject').on('click', function(e) {        
     var ml = $(this).attr('data-modalos-id');   
     var v = $('.navbar-story');      
     $('#'+ml).modalos({topOffset: $(v).position().top + $(v).height() + 30, width:672});
     e.preventDefault();
}); 