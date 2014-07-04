
$(function() {
  $(".grid-wrapper").on("click",".pagination li:not(.active,.disabled) a", function() {  	  	
    $.getScript(this.href);
    window.history.pushState({path:this.href},'',this.href);
    scrolldown(false,'.header');

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

var client = new ZeroClipboard( document.getElementById("copy-button"), {
  moviePath: "/javascripts/ZeroClipboard.swf"
} );

client.on( "load", function(client) {
  client.on( "complete", function(client, args) {
    // `this` is the element that was clicked
    document.getElementById('copied').style.display = 'block';
  } );
} );