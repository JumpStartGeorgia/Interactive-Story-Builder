
/*********************************************************************************************
                                       prepare
**********************************************************************************************/
  var isMobile = function() { return /iPad|iPod|iPhone|Android/.test(navigator.userAgent) || document.location.hash == "#ipad"; }
  var isPhone = function() { return isMobile() && window.innerWidth < 768; }

  // if device is portable we are adding ios class to html tag
  // so new classes with .ios .someclass path are used instead of basic ones
  if (isMobile()) { document.documentElement.className = document.documentElement.className + " ios mob";}

  // array of functions added throught page which should be called at the end of page parsing with "await"
  // function which is called at the bottom of the page
  (function() {
    var defers = [];
    defer = function(f) { defers.push(f); };
    await = function() { defers.forEach(function(f,s) { f();}); };
  })();

  //collecting navigation sections and it's markers
  //binding click events on anchors and navigation section on resize and scroll
  /*defer(function() {
      var anchor = d3.selectAll(".navigation-section").on("click", clicked),
          marker = d3.selectAll(".navigation-marker"),
          markerOffsets;

      d3.select(".navigation-headline").on("click", clicked);

      d3.select(window)
          .on("resize.navigation", resized)
          .on("load.navigation", resized)
          .on("scroll.navigation", scrolled);

      resized();

      function resized() {
        markerOffsets = marker.datum(function(d, i) { return i ? this.offsetTop : 0; }).data();
        scrolled();
      }

      function scrolled() {
        var j = Math.max(0, Math.min(markerOffsets.length - 1, d3.bisectLeft(markerOffsets, pageYOffset + 80) - 1));
        anchor.classed("navigation-section--active", function(d, i) { return i === j; });
      }

      function clicked(d, i) {
        d3.event.preventDefault();
        d3.transition().duration(750).tween("scroll", function() {
          var offset = d3.interpolateNumber(pageYOffset, markerOffsets[i]);
          return function(t) { scrollTo(0, offset(t)); };
        });
      }
    });
  */



/*********************************************************************************************
                                       mobile
**********************************************************************************************/
  if (isMobile())
  {
    mobileReorient();
    defer(function() {
      /* Only do if we're on iPad, iPhone or Android -- TG */
      if (!isMobile()) return false;

      var ipath = path.fullscreen.other.image;
      var spath = path.slideshow.other.image;
      var vpath = path.fullscreen.desktop.video;
      var ppath = path.fullscreen.desktop.poster;

      if (isPhone()) {
        ipath = ipath.replace("mobile_1024", "mobile_640");
        spath  = spath.replace("mobile_1024", "mobile_640");
      }

      d3.select(window)
        .on("resize", mobileReorient)
        .on("scroll", function() {
            d3.select(".navigation")
              .classed("navigation-solid", window.scrollY > 350)
        });

      d3.select(".video-sequence:first-of-type").classed("ios-loaded", true);

      setTimeout(function() {

        var video = d3.selectAll(".section.video-sequence .video")
          .datum(function() { return { video: this.getAttribute("data-video"), image: this.getAttribute("data-image"), }; });

        var video_tag = video.select(".video-container").html("").filter(function(d) { return d.video; })
          .insert("video", ":first-child")
          .attr("preload", "none")
          .attr("poster", function(d) { return  ppath + d.video + ".jpg"; })
          .property("loop", false)
          .property("controls", true)
          .text("Your browser does not support this video.");

        video_tag.append("source")
          .attr("src", function(d) { return vpath + d.video + ".mp4"; })
          .attr("type", "video/mp4");


        var video_tag = video.select(".video-container").filter(function(d) { return d.image; })
          .append("img")
          .attr("src", function(d) { return  ipath + d.image; });

        if(!String.prototype.trim)
        {
          String.prototype.trim = function(c) {
            var r = (!c) ? new RegExp('^\\s+|\\s+$', 'g') : new RegExp('^'+c+'+|'+c+'+$', 'g');
            return this.replace(r, '');
          };
        }

        d3.selectAll(".slideshow").each(function() {
          var wrapper =  d3.select(this).select(".wrapper");
          var captions = wrapper.select('.captions');

          captions.selectAll(".caption").each(function(){
            var t = this;
            if(d3.select(t).text().trim() == "")
            {
              d3.select(t).classed('empty',true);
            }
            captions.insert("div", function() { return t; }).classed("image",true).append("img").attr("src",function(d) { return spath + t.getAttribute("data-image"); });
          });
          wrapper.insert(function(){ return wrapper.select('.description').remove()[0][0]; },".captions");
        });
      }, 200);
    });
    function mobileReorient() {
      var height = window.innerHeight - 40;
      if (height > (720*.59) && window.innerWidth < 768) height = (720*.59);

      var firstVideo = document.querySelector(".video-sequence");
      if(firstVideo !== null && firstVideo.length)
      {
        firstVideo.querySelector(".video:first-of-type .video-container")[0].style.height = height + "px";
        firstVideo.querySelector(".video:first-of-type .video-headline")[0].style.height = height + "px";
      }
    }
  }
/*********************************************************************************************
                                       desktop
**********************************************************************************************/

/* this scripts included when device is not mobile */
    defer(function() {

    /* Just skip if we're on iPad, iPhone or Android -- TG */
    if (isMobile()) return false;

      var vpath = path.fullscreen.desktop.video;
      var ppath = path.fullscreen.desktop.poster;
      var apath = path.fullscreen.desktop.audio;

    var mute = false,
        muteVolume = "volume",
        fixRatio = 16 / 9,
        fixHeight = innerWidth / fixRatio,
        fixTop = Math.round((innerHeight - fixHeight) / 2),
        fadeTop = Math.max(200, fixTop),
        fadeBottom = Math.min(innerHeight - 200, fixTop + fixHeight),
        fade = d3.interpolateRgb("#000", "#fff");

   // var headline = d3.select(".navigation-headline");
    var scrollprompt = d3.select('.scroll-prompt');
    var sequence = d3.selectAll(".video-sequence")
        .datum(function() {
          return {
            first: !this.previousElementSibling,
            audio: this.getAttribute("data-audio"),
            length: this.querySelectorAll(".video").length
          };
        })
        .call(d3.behavior.watch()
          .on("scroll", sequencescrolled)
          .on("statechange", sequencestatechanged));

    sequence.filter(function(d) { return d.audio; }).append("audio")
        .attr("src", function(d) { return apath + d.audio + ".mp3"; })
        .property("loop", true);


    // Add for content to have audio track
    // var section_content = d3.selectAll(".column")
    //     .datum(function() {
    //       return {
    //         audio: this.getAttribute("data-audio")
    //       };
    //     }).call(d3.behavior.watch()
    //       .on("scroll", sequencescrolled)
    //       .on("statechange", sequencestatechanged));


    var section_content = d3.selectAll(".section:not(.video-sequence)[data-audio]")
        .datum(function() {
          return {
            audio: this.getAttribute("data-audio")
          };
        }).call(d3.behavior.watch()
          .on("scroll", sequencescrolled)
          .on("statechange", sequencestatechanged));

    section_content.filter(function(d) { return d.audio; }).append("audio")
        .attr("src", function(d) { return apath + d.audio + ".mp3"; })
        .property("loop", true);
    // content audio end



    var section = d3.selectAll(".video")
        .datum(function() {
          var previous = this.previousElementSibling,
              next = this.nextElementSibling;
          return {
            video: this.getAttribute("data-video"),
            animation: this.hasAttribute("data-animation"),
            loop: this.hasAttribute("data-videoloop"),
            first: !previous || !d3.select(previous).classed("video"),
            last: !next || !d3.select(next).classed("video")
          };
        });

    var sectionFixed = sequence.selectAll(".video")
        .each(function(d) { d.sequence = this.parentNode.__data__; })
        .call(d3.behavior.watch()
          .on("scroll", fixscrolled)
          .on("statechange", fixstatechanged));

    var container = section.select(".video-container");

    var video = container.filter(function(d) { return d.video; }).insert("video", ":first-child")
        .attr("preload", "none")
        .attr("poster", function(d) { return  ppath + d.video + ".jpg"; })
        .property("loop", function(d) { return !d.animation; })
        .property("loop", function(d) { return d.loop; })
        .text("Your browser does not support this video.");

    video.append("source")
        .attr("src", function(d) { return vpath + d.video + ".mp4"; })
        .attr("type", "video/mp4");

    if (!supportsViewportUnits()) sectionFixed.append("div")
        .style("height", fixHeight + "px");

    var containerFixed = sectionFixed.select(".video-container")
        .style("z-index", function(d) { return d.first || d.last ? 1 : 2; })
        .style("position", function(d) { return d.first || d.last ? "absolute" : "fixed"; })
        .style("top", function(d,i) { return d.first || d.last ? null : "0px"; })
        .style("display", function(d) { return d.first || d.last ? null : "none"; });

    containerFixed.select(function(d, i) { return d.sequence.length > 1 ? this : null; }).append("div")
        .attr("class", "video-sequence-indicator")
        .style("margin-top", function(d) { return -d.sequence.length * 1.4 / 2 + "em"; })
        .text(function(d, i) { return d3.range(d.sequence.length).map(function(j) { return i === j ? "●" : "○"; }).join("\n"); });

    var muteButton = d3.select(".navigation-volume").on("click", muted);

    d3.select(window)
        .on("load.video", loaded)
        .on("resize.video", resized);

    d3.select("video").attr("preload", "auto");

    resized();

    function loaded() {
      video.attr("preload", function(d) { return d.first ? "auto" : "none"; });
    }

    function muted() {
      mute = !mute;
      muteVolume = mute ? "_volume" : "volume";
      muteButton.classed("navigation-volume--muted", mute);
      d3.event.preventDefault();
      d3.selectAll("audio,video").interrupt().property("volume", mute
          ? function() { this._volume = this.volume; return 0; }
          : function() { return this._volume; });
    }

    function resized() {

      fixHeight = innerWidth / fixRatio;
      fixTop = Math.round((innerHeight - fixHeight) / 2);
      fadeTop = Math.max(200, fixTop);
      fadeBottom = Math.min(innerHeight - 200, fixTop + fixHeight);
      d3.select(".video-sequence:first-child").style("margin-top", fixTop + "px");
       //containerFixed.style("height", fixHeight + "px")
      containerFixed.style("height", innerHeight+ "px").filter(function(d) { //fixHeight
        var rect = this.parentNode.getBoundingClientRect();
        return d.first ? rect.top < fixTop
            : d.last ? rect.bottom >= fixTop + fixHeight
            : true;
      }).style("top","0px");
      // append height for infographic if height class present
      // if this is a popup interactive, reduce the height more so iframe window is contained within screen
      d3.selectAll(".infographic iframe.height").attr("height", innerHeight);
      d3.selectAll(".infographic .interactive-iframe-popup iframe.height").attr("height", innerHeight-80);
    }

    function fixscrolled(d) {
      if (d.first || d.last) {
        //!(d.first && d.last) && () for bug when media section has only one media
        var fixed = !(d.first && d.last) && ((d.first && d3.event.rect.top < 0)
            || (d.last && d3.event.rect.bottom >= 0 + fixHeight));
        d3.select(this.querySelector(".video-container"))
            .style("z-index", fixed ? 2 : 1)
            .style("top", fixed ? "0px" : null)
            .style("position", fixed ? "fixed" : "absolute");

      }

      var section = d3.select(this),
          container = section.select(".video-container"),
          videoNode = this.querySelector(".video-container video"),
          volume = 1;

      var opacityTop = d3.event.rect.top - fixHeight / 4,
          opacity = opacityTop > fixTop + fixHeight * 4 / 5 ? 0 // previous video fully opaque
            : !d.last && opacityTop < fixTop - fixHeight ? 0 // next video fully covers this video
            : opacityTop < fixTop ? 1 // this video is fully opaque, but may be covered by next video
            : Math.max(0, Math.min(1, 1 - (opacityTop - fixTop) / (fixHeight / 5))); // this video is partially opaque

      if (d.first) {
        if (videoNode) {
          volume = d3.event.rect.top < fixTop + fadeTop ? Math.max(0, Math.min(1, 1 - (d3.event.rect.top - fixTop) / fadeTop)) : 0;
          var play = d3.event.rect.top <= fixTop + fadeTop;
          if (videoNode.paused) {
            if (play && (!d.animation || (videoNode.currentTime < videoNode.duration && volume > .8))) {
              videoNode.play();
            }
          } else if (!play) {
            videoNode.pause();
          }
        }
        container.style("opacity", opacityTop >= fixTop - fixHeight ? 1 : 0);
      } else {
        container.style("opacity", opacity);
        if (videoNode) {
          if (videoNode.paused) {
            if (opacity) {
             if (!d.animation || (videoNode.currentTime < videoNode.duration && opacity > .8)) {
                videoNode.play();
              }
            } else if (videoNode.currentTime) {
              videoNode.currentTime = 0;
            }
          } else if (!opacity) {
            videoNode.pause();
            if (videoNode.currentTime) videoNode.currentTime = 0;
          }
        }
      }

      if (d.last) {
        if (videoNode) {
          volume = d3.event.rect.bottom < fadeBottom ? Math.max(0, Math.min(1, 1 - (fadeBottom - d3.event.rect.bottom) / fadeTop)) : 1;
          var play = d3.event.rect.bottom >= fadeBottom - fadeTop;
          if (videoNode.paused) {
            if (play && (!d.animation || (videoNode.currentTime < videoNode.duration && volume > .8))) {
              videoNode.play();
            }
          } else if (!play) {
            videoNode.pause();
          }
        }
      }

      section.select(".video-caption").style("opacity", opacityTop > fixTop ? (d.first ? 1 : Math.max(0, 1 - (opacityTop - fixTop) / (fixHeight / 5))) // fade in from bottom
          : opacityTop > fixTop - fixHeight * 4 / 5 ? 1 // this video is fully opaque and not covered
          : d.last ? 1 : Math.max(0, (opacityTop - fixTop + fixHeight * 4 / 5) / (fixHeight / 5) + 1)); // fade out to top

      if (videoNode) {
        videoNode[muteVolume] = volume = volume !== 1 ? volume // special-case volume for first and last fade
            : opacityTop < fixTop - fixHeight ? 0 // video is fully covered by next video
            : opacityTop < fixTop - fixHeight / 2 ? Math.max(0, Math.min(1, (opacityTop - fixTop + fixHeight) / (fixHeight / 2)))
            : opacity;
        if (d.first && d.sequence.first) scrollprompt.style("opacity",  volume == 1 ? 1 : (volume-0.7) > 0 ? (volume-0.7) : 0 );
        //if (d.first && d.sequence.first) headline.style("opacity", 1 - volume);
      }
    }

    function fixstatechanged(d) {
      d3.select(this.querySelector(".video-container"))
          .style("display", d3.event.state ? null : "none")
        .select("video")
          .each(function() {
            if (!d3.event.state) {
              if (!this.paused) this.pause();
              if (this.currentTime) this.currentTime = 0;
            }
          });
          if (d.first && d.sequence.first && !d3.event.state) scrollprompt.style("opacity", 1);
      //if (d.first && d.sequence.first && !d3.event.state) headline.style("opacity", null);
    }

    function sequencescrolled() {
      var opacity = Math.max(0, Math.min(1, d3.event.rect.bottom < fadeBottom ? (fadeBottom - d3.event.rect.bottom) / fadeTop
          : d3.event.rect.top < fixTop + fadeTop ? (d3.event.rect.top - fixTop) / fadeTop
          : 1));

      // bug for column background change deny #if(){ data }
      if(!d3.select(this).classed("column"))
      {
        d3.select("body").style("background", fade(opacity));
      }
      d3.select(this).select("audio").property(muteVolume, 1 - opacity);
    }

    function sequencestatechanged() {
      var sequence = d3.select(this),
          audio = sequence.select("audio");
      if (d3.event.state) {
        sequence.selectAll("video").each(function() { this.preload = "auto";});
        audio.each(function() { this.play();  });
      } else {
        d3.select("body").style("background", null);
        audio.each(function() { this.pause(); });
      }
    }

    function supportsViewportUnits() {
      var element = d3.select("body").append("div").style("width", "50vw"),
          expected = innerWidth / 2,
          actual = parseFloat(element.style("width"));
      element.remove();
      return Math.abs(expected - actual) <= 1;
    }

    });



/*********************************************************************************************
                                       slideshow
**********************************************************************************************/
if (!isMobile())
{
  defer(function() {
    var spath = path.slideshow.desktop.image;
    var tpath = path.slideshow.desktop.thumb;

    d3.selectAll(".slideshow").each(function() {
      var currentIndex = 0,
          playInterval;
      var watch = d3.behavior.watch()
          .on("statechange.first", firststatechanged)
          .on("statechange", statechanged);
      var slideshow = d3.select(this).select(".wrapper")
          .on("mouseover", stopPlay)
          .on("mouseout", stopPlay)
          .call(watch);
      var caption = slideshow.select(".captions").selectAll(".caption")
          .datum(function() {
            return {
              image: this.getAttribute("data-image")
            };
          })
          .classed("active", function(d, i) { return i === currentIndex; });
      var images = caption.data();
      var ln = images.length;
      var container = slideshow.insert("div", ".captions")
          .attr("class", "container");
      var image = container.append("div")
          .attr("class", "images")
        .selectAll(".image")
          .data(images)
        .enter().append("img")
          .attr("class", "image");
      image.filter(function(d, i) { return i === currentIndex; })
          .classed("active", true)
          .attr("src", function(d) { return spath + d.image; })
          .each(moveToFront);
      container.append("div")
          .attr("class", "btn btn-next")
          .on("click", function() { stopPlay(); showNext(); })
         .html("<svg class='arrow' width='45' height='59' viewBox='-13 -21 45 59'><path d='M3,1.008L20.742,9.045L3,17.083L6,8.917Z'></path></svg>");
      container.append("div")
          .attr("class", "btn btn-prev")
          .on("click", function() { stopPlay(); showPrevious(); })
        .html("<svg class='arrow' width='45' height='59' viewBox='-13 -21 45 59'><path d='M18.742,0.758L1,8.795L18.742,16.833L15.742,8.667Z'></path></svg>");
      var thumb = container.insert("div", ".captions")
          .attr("class", "thumbs")
        .selectAll(".thumb")
          .data(images)
        .enter().append("img")
          .classed("thumb",true)
          .classed("active", function(d, i) { return (i === currentIndex); })
          .attr("src",function(d) { return tpath + d.image; })
          .on("click", function(d, i) { stopPlay(); show(i); });
      function firststatechanged() {
        if (d3.event.state) {
          image.attr("src", function(d, i) { return spath + d.image; });
          watch.on("statechange.first", null);
        }
      }
      function statechanged() {
        if (d3.event.state) startPlay();
        else stopPlay();
      }
      function startPlay() { if (!playInterval) playInterval = setInterval(showNext, 7000); }
      function stopPlay() { if (playInterval) playInterval = clearInterval(playInterval); }
      function show(index) {
        var oldImage = d3.select(image[0][currentIndex]),
            oldCaption = d3.select(caption[0][currentIndex]),
            oldThumb = d3.select(thumb[0][currentIndex]),
            newImage = d3.select(image[0][index]),
            newCaption = d3.select(caption[0][index]),
            newThumb = d3.select(thumb[0][index]);
        oldImage.classed("active", false);
        oldCaption.classed("active", false);
        oldThumb.classed("active", false);
        newImage
            .classed("active", true)
            .style("opacity", 0)
            .each(moveToFront);
        newCaption.classed("active", true);
        newThumb.classed("active", true);
        currentIndex = index;
        d3.timer(function() { newImage.style("opacity", null); }, 20);
      }
      function showNext() { show((currentIndex + 1) % ln); }
      function showPrevious() { show((currentIndex ? currentIndex : ln) - 1); }
    });
    function moveToFront() { this.parentNode.appendChild(this); }
  });
}
/*********************************************************************************************
                                       watcher and starter
**********************************************************************************************/
(function() {
  var watched = [];
  d3.behavior.watch = function() {
    var event = d3.dispatch("statechange", "scroll");
    function watch(selection) {
      selection.each(function(i) {
        watched.push({
          element: this,
          state: 0,
          index: i,
          event: event
        });
      });
    }
    return d3.rebind(watch, event, "on");
  };
  if (/iPhone|iPad|iPad|Android/.test(navigator.userAgent) || location.hash == "#ipad") {
    d3.select(window)
        .on("resize.watch", watch_scrolledStatic)
        .on("DOMContentLoaded.watch", watch_scrolledStatic);
  } else {
    d3.select(window)
        .on("resize.watch", watch_scrolled)
        .on("scroll.watch", watch_scrolled)
        .on("DOMContentLoaded.watch", watch_scrolled);
  }
  d3.select(window).on("resize.reheight", reheight);
  function reheight () {
    var h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
    d3.selectAll(".section.embed.fullscreen .container > *:first-child").style("height", h + "px");
  }
  function watch_scrolled () {
    watched.forEach(function(watch) {
      var rect = watch.element.getBoundingClientRect();
      if (rect.top + rect.height < 0 || rect.bottom - rect.height - innerHeight > 0) {
        watch_state(watch, 0);
      } else {
        var t = rect.top / (innerHeight - rect.height);
        watch_state(watch, t < 0 || t > 1 ? 1 : 2);
        watch_dispatch(watch, {type: "scroll", offset: t, rect: rect});
      }
    });
  }
  function watch_scrolledStatic () {
    watched.forEach(function(watch) {
      watch_state(watch, 1);
      watch_dispatch(watch, {type: "scroll", offset: .5, rect: {top: 0}}); // XXX rect
    });
  }
  function watch_state (watch, state1) {
    var state0 = watch.state;
    if (state0 !== state1) watch_dispatch(watch, {
      type: "statechange",
      state: watch.state = state1,
      previousState: state0
    });
  }
  function watch_dispatch (watch, event) {
    var element = watch.element,
        sourceEvent = event.sourceEvent = d3.event;
    try {
      d3.event = event;
      watch.event[event.type].call(element, element.__data__, watch.index);
    } finally {
      d3.event = sourceEvent;
    }
  }
  await();
  reheight();
})();
