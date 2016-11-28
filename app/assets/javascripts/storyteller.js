// record that a comment was made
// - this is called from storyteller/index file which is where the disqus code is located
function story_new_comment_callback(url){
  console.log('deprecated');
  // $.ajax
  // ({
  //   url: url + '/record_comment',
  //   dataType: 'json'
  // }).done(function(d) {
  //   // update the comment count on the page
  //   $('#comments-count').html(d.count);
  // });
}


$(document).ready(function(){
    var is_mac = navigator.platform.indexOf('Mac') > -1;
    if($(".navbar-storybuilder").length != 0)
    {
      //$(".navbar-story").css("top","54px");
      var sbn_elem = $(".navbar-storybuilder"), sbn_in_animation = false, sbn_last_scroll;

      addWheelListener(document, function (event) {
        // console.log(event.deltaY);
        if(event.deltaY !== -0 && event.deltaY !== 0) {
          navbar_storybuilder_animate(event.deltaY > 0);
        }
      });
      function navbar_storybuilder_animate (dir) {
        if(!sbn_in_animation) {
          sbn_in_animation = true;
          sbn_last_scroll = null;
          sbn_elem.animate( dir ? { top: -1 * sbn_elem.height() } : { top:"0px" }, 300, function () {
            sbn_in_animation = false;
            if(sbn_last_scroll !== null) {
              navbar_storybuilder_animate(sbn_last_scroll);
            }

          });
        }
        else {
          sbn_last_scroll = dir;
        }
      }
    }

      $('.section.infographic .container .content.infographic').click(function(){
        var t = $(this);
        //var ml =  $('<div id="modalos-infographic"></div>');
        var image =  $('<img>',
        {
            on:
            {
              load: function() {
                console.log(this.width);
                 var v = $('.navbar-storybuilder');
                image.modalos({topOffset: v.position().top + v.height() + 30, leftOffset: 30, width: this.width, height: this.height, paddings:0, margins:0, klass:'infographic', dragscroll:true });

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


      $('.modalEmbed').on('click', function(e) {
        var v = $('.navbar-storybuilder');
        $($('#modalos-embed').get(0).outerHTML).modalos({topOffset: v.position().top + v.height() + 30, width:360, klass:'embed'}); // height:370,
        e.preventDefault();
      });

      $(document).on('click','.embed-type-switcher > div',function(){
        $('.embed-type-switcher > div').each(function(){$(this).toggleClass('selected');});
        var frame_code = $('.embed-code textarea');
        var iframe_width= $(this).data('width');
        var embed_type = 'partial';
        if($(this).hasClass('full'))
        {
          embed_type = 'full';
        }
        frame_code.text("<iframe src='" +  frame_code.attr('data-iframe-link') + "?type="+embed_type+"' width='"+iframe_width+"' height='100%' frameborder='0'></iframe>");
        $('.iframe-size').val(iframe_width);
      });

      $(document).on('change', '.iframe-size', function(){
        var iframe_width=$(this).val();
        var frame_code = $('.embed-code textarea');
        var embed_type = 'partial';

        if($('.embed-type-switcher > div.selected').hasClass('full'))
        {
          embed_type = 'full';
        }
        frame_code.text("<iframe src='" +  frame_code.attr('data-iframe-link') + "?type="+embed_type+"' width='"+iframe_width+"' height='100%' frameborder='0'></iframe>");
      });
  });


// creates a global "addWheelListener" method
// example: addWheelListener( elem, function( e ) { console.log( e.deltaY ); e.preventDefault(); } );
(function(window,document) {

    var prefix = "", _addEventListener, support;

    // detect event model
    if ( window.addEventListener ) {
        _addEventListener = "addEventListener";
    } else {
        _addEventListener = "attachEvent";
        prefix = "on";
    }

    // detect available wheel event
    support = "onwheel" in document.createElement("div") ? "wheel" : // Modern browsers support "wheel"
              document.onmousewheel !== undefined ? "mousewheel" : // Webkit and IE support at least "mousewheel"
              "DOMMouseScroll"; // let's assume that remaining browsers are older Firefox

    window.addWheelListener = function( elem, callback, useCapture ) {
        _addWheelListener( elem, support, callback, useCapture );

        // handle MozMousePixelScroll in older Firefox
        if( support == "DOMMouseScroll" ) {
            _addWheelListener( elem, "MozMousePixelScroll", callback, useCapture );
        }
    };

    function _addWheelListener( elem, eventName, callback, useCapture ) {
        elem[ _addEventListener ]( prefix + eventName, support == "wheel" ? callback : function( originalEvent ) {
            !originalEvent && ( originalEvent = window.event );

            // create a normalized event object
            var event = {
                // keep a ref to the original event object
                originalEvent: originalEvent,
                target: originalEvent.target || originalEvent.srcElement,
                type: "wheel",
                deltaMode: originalEvent.type == "MozMousePixelScroll" ? 0 : 1,
                deltaX: 0,
                deltaY: 0,
                deltaZ: 0,
                preventDefault: function() {
                    originalEvent.preventDefault ?
                        originalEvent.preventDefault() :
                        originalEvent.returnValue = false;
                }
            };

            // calculate deltaY (and deltaX) according to the event
            if ( support == "mousewheel" ) {
                event.deltaY = - 1/40 * originalEvent.wheelDelta;
                // Webkit also support wheelDeltaX
                originalEvent.wheelDeltaX && ( event.deltaX = - 1/40 * originalEvent.wheelDeltaX );
            } else {
                event.deltaY = originalEvent.detail;
            }

            // it's time to fire the callback
            return callback( event );

        }, useCapture || false );
    }

})(window,document);
