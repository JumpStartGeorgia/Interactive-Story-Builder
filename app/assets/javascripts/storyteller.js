/* global $ */
/*eslint no-console: 0 */
$(document).ready(function (){
  var sbn_elem = $(".navbar-storybuilder");
  if(sbn_elem.length != 0)
  {
    var lastScrollTop = 0;
    $(window).on("scroll", function () {
      var st = $(this).scrollTop();
      if(st >= 0) {
        sbn_elem.toggleClass("stealth", st > lastScrollTop ? true : false );
        lastScrollTop = st;
      }
    });
  }

  $(".section.infographic .container .content.infographic").click(function (){
    var t = $(this);
    //var ml =  $("<div id="modalos-infographic"></div>");
    var image = $("<img>", {
      on: {
        load: function () {
          var v = $(".navbar-storybuilder");
          image.modalos({topOffset: v.position().top + v.height() + 30, leftOffset: 30, width: this.width, height: this.height, paddings:0, margins:0, klass:"infographic", dragscroll:true });

        },
        error: function () {
          console.log(this, " - not loaded");
        }
      },
      "src":t.attr("data-original")
    });

  });

  $(".section.infographic .container .content.interactive").click(function (){
    $($(this).find(".interactive-iframe-popup").html()).modalos({topOffset: 50, leftOffset: 0, fullscreen: true, paddings:0, margins:30, klass:"interactive", dragscroll:true });
  });


  $(".modalEmbed").on("click", function (e) {
    var v = $(".navbar-storybuilder");
    $($("#modalos-embed").get(0).outerHTML).modalos({topOffset: v.position().top + v.height() + 30, width:360, klass:"embed"}); // height:370,
    e.preventDefault();
  });

  $(document).on("click", ".embed-type-switcher > div", function (){
    $(".embed-type-switcher > div").each(function () {$(this).toggleClass("selected");});
    var frame_code = $(".embed-code textarea");
    var iframe_width= $(this).data("width");
    var embed_type = "partial";
    if($(this).hasClass("full"))
    {
      embed_type = "full";
    }
    frame_code.text("<iframe src='" + frame_code.attr("data-iframe-link") + "?type="+embed_type+"' width='"+iframe_width+"' height='100%' frameborder='0'></iframe>");
    $(".iframe-size").val(iframe_width);
  });

  $(document).on("change", ".iframe-size", function (){
    var iframe_width=$(this).val();
    var frame_code = $(".embed-code textarea");
    var embed_type = "partial";

    if($(".embed-type-switcher > div.selected").hasClass("full"))
    {
      embed_type = "full";
    }
    frame_code.text("<iframe src='" + frame_code.attr("data-iframe-link") + "?type="+embed_type+"' width='"+iframe_width+"' height='100%' frameborder='0'></iframe>");
  });
});
