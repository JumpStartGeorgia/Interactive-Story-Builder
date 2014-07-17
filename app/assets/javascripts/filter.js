var sa = false; // flag for search box if it is active
var f = {};     // filter values
var pf = {};    // previous filter values
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
  });

// add search phrase to filters
  $(".search-button").click(function(e){ 
    e.preventDefault();
    pf = JSON.parse(JSON.stringify(f));
    f["q"] = $('form#search-filter input#q').val();
    filter();    
  });


// collect all default values for ajax filtering
  $('[data-filter-type]').each(function(v){
    f[$(this).attr('data-filter-type')] = $(this).attr('data-filtered-by');
  });

// staff_pick via ajax
    $('.afilter > a.staff_pick').click(function(e){
      pf = JSON.parse(JSON.stringify(f));

      $(this).toggleClass('active').find('i').toggleClass('i-staffpicked i-staffpick');
      var tmp = !($(this).attr('data-filtered-by') == "true");  
      $(this).attr('data-filtered-by', tmp.toString());   
      f[$(this).attr('data-filter-type')] = tmp.toString();
      e.preventDefault();
      e.stopPropagation();

      filter();
  });
// following via ajax
    $('.afilter > a.following').click(function(e){
      pf = JSON.parse(JSON.stringify(f));

      $(this).toggleClass('active').find('i').toggleClass('i-followed i-follow');
      var tmp = !($(this).attr('data-filtered-by') == "true");  
      $(this).attr('data-filtered-by', tmp.toString());   
      f[$(this).attr('data-filter-type')] = tmp.toString();
      e.preventDefault();
      e.stopPropagation();

      filter();
  });
// category,language,sort via ajax
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

// grid pagination via ajax
  $(".grid-wrapper").on("click",".pagination li:not(.active,.disabled) a", function(e) {        
      var tmp = $(this).attr('data-filter');    
      f["page"] = tmp == "1" ? "":tmp;
      e.preventDefault();
      e.stopPropagation();
      filter();
      scrolldown(false,'.header');

  });

  $('.grid-wrapper').on("click",".pagination .disabled a, .pagination .active a", function(e) {
     e.preventDefault();  
     e.stopPropagation();
  });


});


// for permalink copy 
var client = new ZeroClipboard( document.getElementById("copy-button"), {
  moviePath: "/javascripts/ZeroClipboard.swf"
} );

client.on( "load", function(client) {
  client.on( "complete", function(client, args) {
    // `this` is the element that was clicked
    document.getElementById('copied').style.display = 'block';
  });
});
