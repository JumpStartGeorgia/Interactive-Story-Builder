
var story_id = -1;
var section_id = -1;

var item_id = -1;
var el_type = 's';
var method = 'n';
var tester = null;
$(document).ready(function() {

	$('.story-tree ul').on('click','li.item > .box > .title',function(e) {
		e.preventDefault();
		item_id = -1;
		section_id = $(this).parent().parent().attr('id');
		$('.story-tree ul li').removeClass('active');
		$('.story-tree ul li.item[id='+section_id+']').addClass('active');	    
	    getStory(section_id);
	    return false;
	});
   $('.story-tree ul').on('click','li.item > .box > .collapser',function(e) {
      e.preventDefault();
      section_id = $(this).parent().parent().attr('id');  
      var t = $('.story-tree ul li.item[id='+section_id+']').toggleClass('open').hasClass('open');
      $(this).text( t ? "-" : "+");       
      $(this).parent().parent().children('ul').toggleClass("opened closed"); 
      return false;
   });

	$('.story-tree ul').on('click','li.item > ul > li.sub',function(e) {
		e.preventDefault();		
		item_id = $(this).attr('id');
		section_id = $(this).parent().parent().attr('id');		
		$('.story-tree ul li').removeClass('active');
		//$(this).parent().parent().addClass('active');
		$(this).parent().find('li#'+item_id).addClass('active');   					
		getStory(section_id,item_id);
		if($( "#slideshowAssets" ).length > 0 )
		 $( "#slideshowAssets" ).sortable({ items: "> div" });
	    return false;
	});

  // when media type changes, show the correct file fields
	$('.story-viewer').on('change','input[name="medium[media_type]"]:radio',function(){
		if($(this).val()==1) {
		  $('#mediaImageBox').show();
		  $('#mediaVideoBox').hide();
	  }else {
		  $('#mediaImageBox').hide();
	    $('#mediaVideoBox').show();
    }
    // make sure the file fields are reset when the option changes
    $('form.medium input#mediaImage, form.medium input#mediaVideo').wrap('<form>').parent('form').trigger('reset');
    $('form.medium input#mediaImage, form.medium input#mediaVideo').unwrap();
	});

  $('.story-viewer').on('click', '#btnOlly', function(){
    ths = $('#embedMediaUrl');
	  url = $(ths).val();
    resetEmbedForm();
    
	  if (url.length > 0 && isUrl(url)){
      olly.embed(url, document.getElementById("embedMediaResult"), 'timerOllyCompelte', 'ollyFail');
	  }else{
      ollyFail();
	  }
	});

   $('.story-viewer').on('click', '#btnGetEmbed', function(e){
			
		var id = '';
 		var html = '';
 		var ok = false;
 		var u = $('#youtubeUrl').val();
		$('#youtubeResult').empty();
		$('#youtubeButtons').hide();
		$('#youtubeError').hide();

 		if(u != "")
 		{
 			if(u.length == 11)
 			{
					id = u;
					ok = true;
				}
				else 
				{
				var uri = u.match(/^(?:http(?:s)?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:(?:watch)?\?(?:.*&)?v(?:i)?=|(?:embed|v|vi|user)\/))([^\?&\"'>]+)/)
			  	if(typeof uri[1] !== 'undefined' && uri[1].length == 11)
			  	{
			    	id = uri[1]
			    	ok = true;
			  	}
				}

				if(ok)
				{
					var  pars = ($('#youtubeLoop').is(':checked') ? 'loop=1' : '') + ($('#youtubeInfo').is(':checked') == false ? '&showinfo=0' : '') +
		    ($('#youtubeCC').is(':checked') ? '&cc_load_policy=' + (self.cc ? '1' : '0') : '') + 
		    ( '&hl=' + $('#youtubePlayerLang').val()) + 
		    ( '&cc_lang_pref=' + $('#youtubeCCLang').val());
		    	if(pars[0] == '&')
	    		{
	    			pars = pars.substr(1,pars.length-1);
	    		}	

		  		html =  '<iframe width="640" height="360" src="http://www.youtube.com/embed/' + 
		      	    id + '?' + pars + '" frameborder="0" allowfullscreen class="embed-video embed-youtube"></iframe>';
   	    	$('#youtubeResult').html(html);
   	    	$('#youtubeButtons').show();
				}
				else
				{
			  $('#youtubeUrl').focus();
			  $('#youtubeError').show();
				}
 		}
		e.preventDefault();	
		return true;	
	});

  // when review menu item clicked, open modal 
  // and push in review key and story title
  $(document).on('click', '#btnReviewer', function(e){
		e.preventDefault();		
		
		var ml = $('#' + $(this).attr('data-modalos-id'));   
    var v = $('.navbar-storybuilder'); 
    ml.find('#review_instructions').html(ml.find('#review_instructions').html().replace('[title]', $(this).data('title')));        
    ml.find('#review_url').attr('src', $(this).data('reviewer-key')).html($(this).data('reviewer-key'));        
    ml.modalos({
    	topOffset: $(v).position().top + $(v).height() + 30       	        	        	      
    });

		return true;	
  });

  $(document).on('click', '#btnPublish', function(e){  	
		e.preventDefault();		
		var a = $(this);		
		$.ajax(
		{	
			dataType: "json",
			url: $(this).data('link')}).done(
			function(d) 
			{ 		
				if(typeof(d.e) !== 'undefined' && d.e)	
				{
               if(a.closest('.story-edit').length) a.closest('.story-edit').next('.story-message').html(d.msg).fadeIn(1000);
               else popuper(d.msg,'error');           
				}
				else
					a.find('span:last-child').text(d.title);							
			});	 							
		return true;	
  });
   $('.story-edit-menu ul.nav li > ul.dropdown-menu li').click(function(){$(this).closest('.story-edit').next('.story-message').html("").hide();});

    $(document).on('click', '.preview', function(e){  	
		e.preventDefault();		

        var ml = $('#' + $(this).attr('data-modalos-id'));           
        var v = $('.navbar-storybuilder');
        var type = $(this).data('type');
        var output = '';
        var opts = null;
        var opts_def = 
        {
        	topOffset: $(v).position().top + $(v).height() + 30,        	        
        	paddings :20,
        	contentscroll:false,         
        	width:722
        };
        if(type == 'image')
        {
    	 	output = "<img src='" +  $(this).data('image-path') + "' style='width:640px;'/>";
        }
        else if(type == 'video')
        {
        	output = "<video preload='auto' width='640px' height='auto' controls>" + 
        					"Your browser does not support this video." + 
        					"<source src='"+$(this).data('video-path')+ "' type='"+$(this).data('video-type')+"'>" +
    					  	"</video>";
         opts = {
            topOffset: $(v).position().top + $(v).height() + 30,                   
            paddings :20,
            contentscroll:false,
            width:722,
            before_close:function(t)
            {
               $(t).find('video').each(function(){ this.pause(); })
               $(t).find('audio').each(function(){ this.pause(); })               
            }
         };
        }
        else if(type == 'text')
    	{
    		output = $("#contentArticle").val();
    	}
    	else if(type=='story')
    	{
    		output = "<iframe height='100%' width='100%' src='"+$(this).data('link') + "?n=n"+"'></iframe>";
    		opts = {
				topOffset: $(v).position().top + $(v).height(),
	        	fullscreen:true,
	        	aspectratio:true,
	        	paddings :0,
	        	contentscroll:false,
             before_close:function(t)
            {              
               $(t).find("iframe").contents().find("video").each(function(){this.pause();})          
               $(t).find("iframe").contents().find("audio").each(function(){this.pause();})              
            }
    		};

    	}
    	if(opts===null) opts = opts_def;    	
        ml.html(output).modalos(opts);

		return true;	
  });


	$('#btnUp').click(function(){
		if(!(section_id == -1 && item_id == -1))
		{
			if (el_type == 'content') return true;
			var dataTemp = {'s' : section_id, 'i': item_id };
			$.ajax
			({
				url: 'up',			  
				data: dataTemp,
				type: "POST",			
		        dataType: 'json'

			}).done(function(d) 
			{
				var secT = $('.story-tree ul li.item[id='+ section_id + ']');
				if(item_id == -1)
				{			 	
			 		if( secT.prev().length)
			 		{
		 			  $(secT).insertBefore($(secT).prev());
			 		}
		 		}
		 		else
		 		{
		 			subT = secT.find('ul li.sub[id='+item_id+']');
		 			if( subT.prev().length)
			 		{
		 			  $(subT).insertBefore($(subT).prev());
			 		}
		 		}	
						
			}).error(function(e){ popuper(gon.fail_change_order,"error");});	
		} 	
	});


	
	$('#btnDown').click(function(){
		if(!(section_id == -1 && item_id == -1))
		{
			if (el_type == 'content') return true;
			var dataTemp = {'s' : section_id, 'i': item_id };
			$.ajax
			({
				url: 'down',			  
				data: dataTemp,
				type: "POST",			
		        dataType: 'json'

			}).done(function(d) 
			{
			 	var secT = $('.story-tree ul li.item[id='+ section_id + ']');

				if(item_id == -1)
				{			 	
			 		if( secT.next().length)
			 		{
		 			  $(secT).insertAfter($(secT).next());
			 		}
		 		}
		 		else
		 		{
		 			subT = secT.find('ul li.sub[id='+item_id+']');
		 			if( subT.next().length)
			 		{
		 			  $(subT).insertAfter($(subT).next());
			 		}
		 		}		 				
			}).error(function(e){ popuper(gon.fail_change_order,"error");});	
		} 	
	});
	$('.story-viewer').on("click",'#btn-up-slideshow', function() {
  			var secT = $(this).parents('.fields');
  			if( !secT.prev().length) return false;
  			
  			// if this is a new record and no id exists yet, 
  			// don't make ajax call, just move it
			  if ($(this).data('id') == 0){
			    if( secT.prev().length)
	     		{
     			   $(secT).insertBefore($(secT).prev());
	     		}				
			  }else{
			    $.ajax
			    ({
				    url: 'up_slideshow',			  
				    data: {asset_id: $(this).data('id')},
				    type: "POST",			
		            dataType: 'json'

			    }).done(function(d) 
			    {
				    if( secT.prev().length)
		     		{
	     			   $(secT).insertBefore($(secT).prev());
		     		}				
						
			    }).error(function(e){ popuper(gon.fail_change_order,"error");});	
			  }
	});
		$('.story-viewer').on("click",'#btn-down-slideshow', function() {
			var secT = $(this).parents('.fields');
			if( !secT.next().length) return false;

			// if this is a new record and no id exists yet, 
			// don't make ajax call, just move it
		  if ($(this).data('id') == 0){
			  if( secT.next().length)
	   		{
   			  $(secT).insertAfter($(secT).next());
	   		}
      } else {
			  $.ajax
			  ({
				  url: 'down_slideshow',			  
				  data: {asset_id: $(this).data('id')},
				  type: "POST",			
		          dataType: 'json'

			  }).done(function(d) 
			  {
				  if( secT.next().length)
		   		{
	   			  $(secT).insertAfter($(secT).next());
		   		}
						
			  }).error(function(e){ popuper(gon.fail_change_order,"error");});	
      }


	});
	$('#btnDelete').click(function(){

	
		if(section_id == -1 ) { popuper(gon.nothing_selected,"notice"); return true;}


		var c=confirm(gon.confirm_delete);
		if (!c) return true;
		  

		var dataTemp = {'_method':'delete','section_id' : section_id, 'type':el_type };
		
		if(el_type!='s') 
		{		
			dataTemp['item_id'] = item_id;
		}
		$.ajax
		({
			url: 'tree',			  
			data: dataTemp,
			type: "POST",			
	        dataType: 'json'

		}).done(function(d) 
		{
		 	var secT = $('.story-tree ul li.item[id='+ section_id + ']');
			if(item_id != -1)
			{
				if(secT.find('ul li').length == 1)
					secT.find('ul li.sub[id='+item_id+']').parent().remove();		
				else secT.find('ul li.sub[id='+item_id+']').remove();		
			}
			else 
			{	
				secT.remove();		
			}
			$('.story-viewer').html('');
			getStory(-1,-1)
			$("html, body").animate({ scrollTop: 0 }, "slow");
					
		}).error(function(e){ popuper(gon.fail_delete,"error");});

		return true;	
	});


	$('#btnAddSection').click(function(){ method = 'n';	el_type = 's';  getStory(-1,-1,1);});

	$('#btnAddItem').click(function(){	
		var temp;
		if(section_id == -1) {alert(gon.msgs_select_section); return true;}
		else  { temp = $('.story-tree ul li.item[id='+ section_id + ']'); }
		
		var tempType = temp.data('type');
		if( tempType == 'content' && temp.has('ul').length==1 )
		{			
			alert(gon.msgs_one_section_content);
		}
		else if( tempType == 'slideshow' && temp.has('ul').length==1 )
		{			
			alert(gon.msgs_one_section_slideshow);
		}
		else if( tempType == 'embed_media' && temp.has('ul').length==1 )
		{			
			alert(gon.msgs_one_section_embed_media);
		}
		else if( tempType == 'youtube' && temp.has('ul').length==1 )
		{			
			alert(gon.msgs_one_section_youtube);
		}
		else 
		{		
			method = 'n';
			el_type = tempType;				
			getData();
		}	
	});

  // trigger the add content form if no sections exist
  if (gon.has_no_sections == true){
	  $('#btnAddSection').trigger('click');
  }
  
  var was_title_box_length, was_permalink_box_length = 0;
  
  // if the title changes and there is no permalink or the permalink was equal to the old title, 
  // add the title into the permalink show field
  $('input#storyTitle').bind('keyup', debounce(function () {
    if (($('input#storyPermalinkStaging').val() != '' && $('input#storyPermalinkStaging').val() !== $(this).data('title-was')) || 
        $(this).val().length == was_title_box_length) {
        
      return;
    } else {
      $(this).data('title-was', $(this).val());
      $('input#storyPermalinkStaging').val($(this).val());
      check_story_permalink($(this).val());
    }

    was_title_box_length = $(this).val().length;
  }));
  
  // if the permalink staging field changes, use the text to generate a new permalink
  $('input#storyPermalinkStaging').bind('keyup', debounce(function () {
    // if text length is 1 or the length has not changed (e.g., press arrow keys), do nothing
    if ($(this).val().length == 1 || $(this).val().length == was_permalink_box_length) {
      return;
    } else {
      check_story_permalink($(this).val());
    }

    was_permalink_box_length = $(this).val().length;
  }));
  
  // when the page loads, show the permalink if it exists  
  if ($('#story_permalink').length > 0 && $('input#storyPermalink').val().length > 0){
    was_title_box_length = $('input#storyTitle').val().length;
    was_permalink_box_length = $('input#storyPermalinkStaging').val().length;;
    show_story_permalink({'is_duplicate': false, 'permalink':$('input#storyPermalink').val()});
  }

  // add autocomplete for tags
  if ($('#storyTagList').length > 0){
    $('#storyTagList').tokenInput(
      gon.tag_search,
      {
        method: 'POST',
        minChars: 2,
        theme: 'facebook',
        allowCustomEntry: true,
        preventDuplicates: true,
        prePopulate: $('#storyTagList').data('load'),
        hintText: gon.tokeninput_tag_hintText,
        noResultsText: gon.tokeninput_tag_noResultsText,
        searchingText: gon.tokeninput_searchingText
      }
    ); 
  }
  
  // add autocomplete for collaborator search
  if ($('form#collaborators #collaborator_ids').length > 0){
    $('form#collaborators #collaborator_ids').tokenInput(
      gon.collaborator_search,
      {
        method: 'POST',
        minChars: 2,
        theme: 'facebook',
        allowCustomEntry: true,
        preventDuplicates: true,
        prePopulate: $('form#collaborators #collaborator_ids').data('load'),
        hintText: gon.tokeninput_collaborator_hintText,
        noResultsText: gon.tokeninput_collaborator_noResultsText,
        searchingText: gon.tokeninput_searchingText,
        resultsFormatter: function(item){ 
          return "<li><img src='" + item.img_url + "' title='" + item.name + "' height='28px' width='28px' /><div style='display: inline-block; padding-left: 10px;'><div>" + item.name + "</div></div></li>" 
        },        
        tokenFormatter: function(item) { 
          if (item.img_url == undefined){
            return "<li><p>" + item.name + "</p></li>" ;
          }else{
            return "<li><p><img src='" + item.img_url + "' title='" + item.name + "' height='50px' width='50px' /></p></li>" ;
          }
        }
      }
    ); 
  }
  
  // remove collaborator
  $('#current-collaborators a.remove-collaborator').click(function(e){
		e.preventDefault();		
    var ths = this;
    $.ajax
    ({
	    url: $(ths).data('url'),			  
	    data: {user_id: $(ths).data('id')},
	    type: "POST",			
      dataType: 'json'
    }).done(function(d) {
      var dng = 'alert-danger';
      var info = 'alert-info';
      var cls = dng;
      if (d.success){
        // hide user
        $(ths).closest('li').fadeOut();
        cls = info;
      }
      // show message
      $('li#remove-collaborator-message').show().removeClass(dng).removeClass(info).addClass(cls).html(d.msg);
    });
  });
});

function show_story_permalink(d){
  var div = '#story_permalink';
  // show the permalink
  if ($(div + ' > span.check_permalink').length == 0){
    // not exists, so create div
    $(div).html('<span class="check_permalink"></span>');
  }else{
    // exists, so clear out
    $(div + ' > span.check_permalink').empty();
  }
  
  // add the result
  var html = '';
  if (d.is_duplicate == true){
    $(div + ' > span.check_permalink').addClass('duplicate').removeClass('not_duplicate');
    html = gon.story_duplicate;
  }else{
    $(div + ' > span.check_permalink').addClass('not_duplicate').removeClass('duplicate');
  }
  html += ' ' + gon.story_url + ' /' + d.permalink;
  
  $(div + ' > span.check_permalink').html(html);
}

function check_story_permalink(text){
  if (text != ''){
    var data = {text: text};
    var url = window.location.href.split('/');
    if (url[url.length-1] == 'edit'){
      data.id = url[url.length-2];
    }
    $.ajax
    ({
	    url: gon.check_permalink,			  
	    data: data,
	    type: "POST",			
      dataType: 'json'
    }).done(function(d) { 
      // record the new permalink
      $('input#storyPermalink').val(d.permalink);

      // show the permalink 
      show_story_permalink(d);
    });
  }else{
    $('#story_permalink > span.check_permalink').empty().removeClass('not_duplicate').removeClass('duplicate');
  }
}


function resetEmbedForm(){
  timerCount = 0;
  $('#embedMediaCode').empty();
  $('#embedMediaResult').empty();
  $('#embedMediaButtons').hide();
  $('#embedMediaError').hide();
}
function ollyFail(){
  resetEmbedForm();
  $('#embedMediaUrl').focus();
  $('#embedMediaError').show();
}
function timerOllyCompelte() {
timerCount += 1;
  if ($('#embedMediaResult').html().length > 0){
    $('#embedMediaCode').val($('#embedMediaResult').html());
    $('#embedMediaButtons').show();
  }else{
    setTimeout(function() {
        timerOllyCompelte();
    }, 500)
  }
}

function isUrl(s) {
  var regexp = /(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
  return regexp.test(s);
}


function getStory(id , subid , state)
{
	id = typeof id !== 'undefined' ? id : -1;
	subid = typeof subid !== 'undefined' ? subid : -1;
	state = typeof state !== 'undefined' ? state : -1;
	if(id != -1)
	{
		var selectedSection = $('.story-tree ul li.item[id='+ id + ']');
		el_type = selectedSection.data('type');	
	}		

	if(subid != -1)
	{		
		method = 's';		
		getData();
					
	}
	else if(id != -1)
	{		
		el_type='s';
		method = 's';
		getData();					
	}
	else
	{
		item_id = -1;
		section_id = -1;
		$('.story-tree ul li').removeClass('active');
		if(state == 1) getData();
		//if(el_type)
		//el_type = 's'; 
		//method = 'new';

	}
}
function getData()
{
	var dataTemp = {'section_id' : section_id, 'command':method, 'type':el_type};
	
	if(el_type!='s') 
	{		
		dataTemp['item_id'] = item_id;
	}

	$.ajax
		({
		  url: 'get_data',
		  data: dataTemp,
		  dataType: 'script',
	      cache: true 
		}).error(function(e){console.log(e)}).done(function(){			
         if(el_type!='s' && method != 'n')
            $('.form-title .form-title-text').text($('.story-tree > ul > li.item[id='+section_id+'].open > ul > li.sub.active > div > .sub-l').text() + ": " + $('.form-title .form-title-text').text());
		});

	return true;	
}

function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
}

function add_fields(link, association, content) {
  	var new_id = new Date().getTime();
  	var regexp = new RegExp("new_" + association, "g")
	$('#slideshowAssets').append(content.replace(regexp, new_id));
}

