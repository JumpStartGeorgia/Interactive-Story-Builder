$(document).ready(function(){
	var info = false;

	var currentScroll=0;
	var infoOffset = 40;
	$('.story-menu').click(function()
	{		
		
		if(info)
		{
			$('body').css("overflow","visible");
		 	$('.story-info-wrapper').fadeOut();
		}
        else
        {

			$('body').css("overflow","hidden");
			$('.story-info-wrapper').height($(window).height() - 60 - infoOffset);
		$('.story-info-wrapper').width($(window).width() - infoOffset);
		$('.story-info-wrapper').css("top",infoOffset/2 + 60);
		$('.story-info-wrapper').css("left",infoOffset/2);
			$('.story-info-wrapper').fadeIn();
		}
	 	info=!info;

	});
});