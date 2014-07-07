$(document).ready(function() {  
    
  $('.search-box input#q').show();
  // if a search term already exists, show the search box
  if ($('form#search-filter input#q').val() !== ''){
     $(".search-box").addClass("active");
     //$(".search-label").hide();  
     sa = true;      
  }
  if(gon.page_filtered) { scrolldown(false,'.header'); }
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

$('.search-box input#q').keyup(function(e) {    
    var code = e.keyCode || e.which;
    if (code == '9') {
      searchHoverIn();
    }
 });
  // show search box on hover
  //$('.search-label').hover(searchHoverIn,jQuery.noop());
  $('.search-box').hover(searchHoverIn,searchHoverOut);

  // add search phrase to filters
  $('form#search-filter').submit(function(e){
    e.preventDefault();
    pf = JSON.parse(JSON.stringify(f));
    f["q"] = $('form#search-filter input#q').val();
    filter();
    //window.location.href = UpdateQueryString('q', $('form#search-filter input#q').val());
  });

  // add search phrase to filters
  $(".search-button").click(function(e){ 
    e.preventDefault();
    pf = JSON.parse(JSON.stringify(f));
    f["q"] = $('form#search-filter input#q').val();
    filter();
    //window.location.href = UpdateQueryString('q', $('form#search-filter input#q').val());
  });
  
  // clear the search box
  // $("#clear-search").click(function(e){
  //   e.preventDefault();
  //   $('form#search-filter input#q').val('')
  //   $(".search-box input#q").focus();
  // });
  // on page refresh matched stories count are visualized with css styled progress indicator with showing overal matched stories
  //match_ui();

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
function url_update() {
  var url = window.location.href;

  for (prop in f) 
  {
    if (!f.hasOwnProperty(prop)) {continue;}   
    var k = prop;
    var v = f[prop];

    var re = new RegExp("([?&])" + k + "=.*?(&|#|$)(.*)", "gi");

    if (re.test(url)) {
        if (typeof v !== 'undefined' && v !== null && v !== '')
            url = url.replace(re, '$1' + k + "=" + v + '$2$3');
        else {
            var hash = url.split('#');
            url = hash[0].replace(re, '$1$3').replace(/(&|\?)$/, '');
            if (typeof hash[1] !== 'undefined' && hash[1] !== null) 
                url += '#' + hash[1];            
        }
    }
    else {
        if (typeof v !== 'undefined' && v !== null && v !== '') {
            var separator = url.indexOf('?') !== -1 ? '&' : '?',
                hash = url.split('#');
            url = hash[0] + separator + k + '=' + v;
            if (typeof hash[1] !== 'undefined' && hash[1] !== null) 
                url += '#' + hash[1];            
        }          
    }
  }  
  if(url!=window.location){
    window.history.pushState({path:url},'',url);
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
                      
// // matcher
// var p=1; // steps for match to finish
// var steps = 20;
// var matches = $('#showProgress').data('matches');
// var step = matches/steps;
// function match_ui() 
// {  
//   if(p > steps/2)
//     $('#showProgress #slice:not([class*="gt50"])').addClass('gt50').append('<div class="pie fill"></div>');
//   //$('#showProgress').html('<div class="percent"></div><div id="slice"'+(p > steps/2?' class="gt50"':'')+'><div class="pie"></div>'+(p > steps/2 ?'<div class="pie fill"></div>':'')+'</div>');

//   var deg = 360/steps*p;
//   $('#showProgress #slice .pie').css({
//   '-moz-transform':'rotate('+deg+'deg)',
//   '-webkit-transform':'rotate('+deg+'deg)',
//   '-o-transform':'rotate('+deg+'deg)',
//   'transform':'rotate('+deg+'deg)'
//   }); 

//   $('#showProgress .percent').text(Math.ceil(step*p));  

//   if(p!=steps) 
//   {
//     setTimeout('match_ui()', 50);
//   }
//   p++;
// }
// // matcher   
var f = {};   
var pf = {};
function filter()    
{    
  console.log(f);
  if(JSON.stringify(f) !== JSON.stringify(pf))
  {  
    var ftmp = {};
    for (prop in f) 
    {
      var k = prop;
      var v = f[prop];
      if (!f.hasOwnProperty(prop)) {continue;}  
      if (typeof v !== 'undefined' && v !== null && v !== '') 
      {
        ftmp[k] = v;
      }

    }
    $.ajax({       
      type: "POST",
      url: gon.filter_path,
      dataType: "json",
      data: ftmp
    }).done(function(data) {          
      $(".grid-wrapper").html($(data.d).children());
      url_update();
    });
  }  
}
$(document).ready(function() {  
  
  $('[data-filter-type]').each(function(v){
    f[$(this).attr('data-filter-type')] = $(this).attr('data-filtered-by');
  });

    $('.afilter > a.staff_pick').click(function(e){
      pf = JSON.parse(JSON.stringify(f));

      $(this).toggleClass('active').find('i').toggleClass('i-staffpicked i-staffpick');
      var tmp = !($(this).attr('data-filtered-by') == "");  
      $(this).attr('data-filtered-by', tmp ? "":"false");   
      f[$(this).attr('data-filter-type')] = tmp?"":"false";
      e.preventDefault();
      e.stopPropagation();

      filter();
  });

  $('.afilter > ul.afilter-list > li > a').click(function(e){    

      pf = JSON.parse(JSON.stringify(f));
      var par = $(this).closest('.afilter').find('> a');
      $(this).closest('.afilter').find('> ul > li > a').removeClass('active');
      $(this).addClass('active');

      var f_type = par.attr('data-filter-type');      
      var f_value = $(this).attr('data-filter'); 

      

      if(f_value == par.attr('data-filter-default')) 
      {
        par.find('span').text(par.is('[data-filter-default-label]') ? par.attr('data-filter-default-label') : $(this).text());
        par.removeClass('selected');
        f[f_type] = ''; 
        par.attr('data-filtered-by',"");
      }
      else
      {
       // console.log($(this).attr('data-filter'));
        par.find('span').text($(this).text());
        par.addClass('selected');
        f[f_type] = f_value; 
        par.attr('data-filtered-by',f_value);
      }
    

      e.preventDefault();
      e.stopPropagation();

      filter();         
  });
});