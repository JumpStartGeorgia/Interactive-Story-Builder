
$(function() {
  $(".grid-wrapper").on("click",".pagination li:not(.active,.disabled) a", function() {  	  	
    $.getScript(this.href);
    window.history.pushState({path:this.href},'',this.href);
	$("html,body").stop().animate({
	      scrollTop: 550
	}, 1000);

    return false;
  });
  // $("#products_search input").keyup(function() {
  //   $.get($("#products_search").attr("action"), $("#products_search").serialize(), null, "script");
  //   return false;
  // });


  $('.grid-wrapper').on("click",".pagination .disabled a, .pagination .active a", function(e) {
	   e.preventDefault();	
	});
});