
$( document ).ready(function() {
    	$('#section_type').change(
    		function(){
    			if($(this).find("option:selected").val()=="Column")
    			{ $('#section_column').show();$('#section_video').hide();}
	    		else
	    		{$('#section_column').hide();$('#section_video').show();}
    		
    		});
    		
            $('#section_audio').change(function(){
               if($(this).is(':checked'))
                    $('#section_audio_upload').show();
                else $('#section_audio_upload').hide();               
            });
    	  
    });
	
	function calling(){alert("here");}


$(function () {
    $('.tree li:has(ul)').addClass('parent_li').find(' > span').attr('title', 'Collapse this branch');
    $('.tree li.parent_li > span').on('click', function (e) {
        var children = $(this).parent('li.parent_li').find(' > ul > li');
        if (children.is(":visible")) {
            children.hide('fast');
            $(this).attr('title', 'Expand this branch').find(' > i').addClass('icon-plus-sign').removeClass('icon-minus-sign');
        } else {
            children.show('fast');
            $(this).attr('title', 'Collapse this branch').find(' > i').addClass('icon-minus-sign').removeClass('icon-plus-sign');
        }
        e.stopPropagation();
    });
});

