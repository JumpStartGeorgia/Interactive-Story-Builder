$(document).ready(function() {  
    
  $('.search-box input#q').show();
  // if a search term already exists, show the search box
  if ($('form#search-filter input#q').val() !== ''){
     $(".search-box").addClass("active");
     //$(".search-label").hide();  
     sa = true; 
     scrolldown(false);
  }

  // hide the search box when leave
  $('.search-box input#q').focusout(function(){
    if($(this).val().length==0)
    {
      $(".search-box").removeClass("active");
     //   $(".search-box input#q").hide();
      //$(".search-label").show();                     
      sa = false;
    }
  });

  // show search box on hover
  //$('.search-label').hover(searchHoverIn,jQuery.noop());
  $('.search-box').hover(searchHoverIn,searchHoverOut);

  // add search phrase to filters
  $('form#search-filter').submit(function(e){
    e.preventDefault();
    window.location.href = UpdateQueryString('q', $('form#search-filter input#q').val());
  });

  // add search phrase to filters
  $(".search-button").click(function(e){ 
    e.preventDefault();
    window.location.href = UpdateQueryString('q', $('form#search-filter input#q').val());
  });
  
  // clear the search box
  $("#clear-search").click(function(e){
    e.preventDefault();
    $('form#search-filter input#q').val('')
    $(".search-box input#q").focus();
  });
  // on page refresh matched stories count are visualized with css styled progress indicator with showing overal matched stories
  match_ui();

});

  // taken from: http://stackoverflow.com/questions/5999118/add-or-update-query-string-parameter
  function UpdateQueryString(key, value, url) {
      if (!url) url = window.location.href;
      var re = new RegExp("([?&])" + key + "=.*?(&|#|$)(.*)", "gi");

      if (re.test(url)) {
          if (typeof value !== 'undefined' && value !== null && value !== '')
              return url.replace(re, '$1' + key + "=" + value + '$2$3');
          else {
              var hash = url.split('#');
              url = hash[0].replace(re, '$1$3').replace(/(&|\?)$/, '');
              if (typeof hash[1] !== 'undefined' && hash[1] !== null) 
                  url += '#' + hash[1];
              return url;
          }
      }
      else {
          if (typeof value !== 'undefined' && value !== null && value !== '') {
              var separator = url.indexOf('?') !== -1 ? '&' : '?',
                  hash = url.split('#');
              url = hash[0] + separator + key + '=' + value;
              if (typeof hash[1] !== 'undefined' && hash[1] !== null) 
                  url += '#' + hash[1];
              return url;
          }
          else
              return url;
      }
  }

var sa = false; // flag for search box if it is active
function searchHoverIn()
{
  if(!sa)
    {              
       $(".search-box").addClass("active");               
       $(".search-box input#q").focus();
       //$(".search-label").hide();
       sa = true;                
    }
}
function searchHoverOut()
{

  if(($(this).find("input#q").val() === undefined || $(this).find("input#q").val().length==0) && sa)
  {            
        $(".search-box input#q").trigger("blur");
         $(".search-box").removeClass("active");                  
         //$(".search-label").show();  
         sa = false; 
  }
}
                      
// matcher
var p=1; // steps for match to finish
var steps = 20;
var matches = $('#showProgress').data('matches');
var step = matches/steps;
function match_ui() 
{  
  if(p > steps/2)
    $('#showProgress #slice:not([class*="gt50"])').addClass('gt50').append('<div class="pie fill"></div>');
  //$('#showProgress').html('<div class="percent"></div><div id="slice"'+(p > steps/2?' class="gt50"':'')+'><div class="pie"></div>'+(p > steps/2 ?'<div class="pie fill"></div>':'')+'</div>');

  var deg = 360/steps*p;
  $('#showProgress #slice .pie').css({
  '-moz-transform':'rotate('+deg+'deg)',
  '-webkit-transform':'rotate('+deg+'deg)',
  '-o-transform':'rotate('+deg+'deg)',
  'transform':'rotate('+deg+'deg)'
  }); 

  $('#showProgress .percent').text(Math.ceil(step*p));  

  if(p!=steps) 
  {
    setTimeout('match_ui()', 50);
  }
  p++;
}
// matcher

