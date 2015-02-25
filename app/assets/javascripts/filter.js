var sa = false; // flag for search box if it is active
var f = { page : ''};     // filter values
var pf = {};    // previous filter values
var paging = false;
var grid_wrapper = $(".grid-wrapper");
var grid = grid_wrapper.find(".grid");

function filter()    
{    
  if(JSON.stringify(f) !== JSON.stringify(pf))
  { 
    var ftmp = {};   

    if(!paging) { f['page'] = ''; } 

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
    if(!paging) grid.html("");
    if(!grid_wrapper.find('.loading').length) grid_wrapper.append('<div class="loading"></div>');
    if(!paging) grid_wrapper.find('.loading').addClass('space');
    $.ajax({       
      type: "POST",
      url: gon.filter_path,
      dataType: "json",
      data: ftmp
    }).done(function(data) { 

      setTimeout(function(){    
      data = $(data.d);
      
      var len = data.find('.grid .col').length;

      grid_wrapper.find(".loading").remove(); 

      data.find('.grid .col').each(function(i,d)
      {      
        setTimeout(function() 
        {
          grid.append($(d).hide().fadeIn(2000)); 
          if(i == len-1)
          {
            paging = false;
          }
        } ,300*i);
      }); 
      if(len == 0)
      {  
        grid.append(data.find('p').hide().fadeIn(2000)); 
      }
      grid_wrapper.find(".pagination-wrapper").html(data.find('.pagination-wrapper').html());
      url_update();
      


      },1000);
    });
  }  
  
}
function url_update() {
  var url = window.location.href;

  for (prop in f) 
  {
    if (!f.hasOwnProperty(prop)) {continue;} 
    if (prop  == 'page') { continue; }
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



$(document).ready(function() {  

if(gon.page_filtered) { scrolldown(false,'header'); }

// collect all default values for ajax filtering
  $('[data-filter-type]').each(function(v){
    f[$(this).attr('data-filter-type')] = $(this).attr('data-filtered-by');
  });

// not_published via ajax
    $('.afilter > a.not_published').click(function(e){
      pf = JSON.parse(JSON.stringify(f));

      $(this).toggleClass('active');
      var tmp = !($(this).attr('data-filtered-by') == "true");  
      $(this).attr('data-filtered-by', tmp.toString());   
      f[$(this).attr('data-filter-type')] = tmp.toString();
      if (tmp){
        $(this).attr('title', $(this).data('title-active'));
      }else{
        $(this).attr('title', $(this).data('title'));
      }
      e.preventDefault();
      e.stopPropagation();

      filter();
  });
// following via ajax
    $('.afilter > a.following').click(function(e){
      pf = JSON.parse(JSON.stringify(f));

      $(this).toggleClass('active').find('i').toggleClass('h v');
      var tmp = !($(this).attr('data-filtered-by') == "true");  
      $(this).attr('data-filtered-by', tmp.toString());   
      f[$(this).attr('data-filter-type')] = tmp.toString();
      if (tmp){
        $(this).attr('title', $(this).data('title-active'));
      }else{
        $(this).attr('title', $(this).data('title'));
      }
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
      paging = true;
      e.preventDefault();
      e.stopPropagation();
      filter();
//      scrolldown(false,'.header');

  });
 $(document).on('scroll DOMMouseScroll mousewheel', function() {
    var url = $('.pagination .next_page a').attr('href');
    if (url && url !='#' && $(window).scrollTop() >= $(document).height() - $(window).height() - 120)
    {
      var tmp = $('.pagination .next_page a').attr('data-filter');    
      f["page"] = tmp == "1" ? "":tmp;
      if(!paging) 
      {
        paging = true;
        filter();
      }
    }
  });

  $('.grid-wrapper').on("click",".pagination .disabled a, .pagination .active a", function(e) {
     e.preventDefault();  
     e.stopPropagation();
  });


});


