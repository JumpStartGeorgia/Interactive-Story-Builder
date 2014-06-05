//= require jquery.reveal
//= require jquery.ui.dialog
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.bootstrap


var story_id = -1;
var section_id = -1;

var item_id = -1;
var el_type = 's';
var method = 'n';

$(document).ready(function() {



	$('.story-tree ul').on('click','li.item',function(e) {
		e.preventDefault();
		item_id = -1;
		section_id = $(this).attr('id');
		$('.story-tree ul li').removeClass('active');
		$('.story-tree ul li.item[id='+section_id+']').addClass('active');
	    $(this).children('ul').toggle();	     
	    getStory(section_id);
	    return false;
	});

	$('.story-tree ul').on('click','li.item > ul > li.sub',function(e) {
		e.preventDefault();		
		item_id = $(this).attr('id');
		section_id = $(this).parent().parent().attr('id');		
		$('.story-tree ul li').removeClass('active');
		parent = $(this).parent().parent().addClass('active');
		$(this).parent().find('li#'+item_id).addClass('active');   					
		getStory(section_id,item_id);
		 $( "#slideshowAssets" ).sortable({ items: "> div" });
	    return false;
	});

	$('.story-viewer').on('change','#mediaType',function(){
		if($(this).val()==1) $('#mediaVideoBox').hide();
		else  $('#mediaVideoBox').show();
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

	
	// $('.story-viewer').on('change','#sectionType',function(){		
	// 	if($(this).val()==1) $('#sectionAudioBox').hide();
	// 	else $('#sectionAudioBox').show();
	// });
	


    $('#publishedStoryTable').dataTable({
 		"sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
 		"sPaginationType": "bootstrap",	  	
		"bAutoWidth": true,    	
	    "oLanguage": {
	      "sUrl": gon.datatable_i18n_url
	    },	        	
    	"aoColumns": [
	      { "bSortable": true },
	      { "bSortable": true },				      	     
	      { "bSortable": false }		
	    ]
    }); 
    $('#storiesTable').dataTable({
 		"sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
 		"sPaginationType": "bootstrap",	  	
		"bAutoWidth": true,    	
	    "oLanguage": {
	      "sUrl": gon.datatable_i18n_url
	    },	    
    	//"aaSorting": [[2, 'desc']]
    	"aoColumns": [
	      { "bSortable": true },
	      { "bSortable": true },				      	     
	      { "sWidth": "25px", "bSortable": false },
	      { "sWidth": "25px", "bSortable": false },
			{"sWidth": "25px", "bSortable": false },
			{"sWidth": "25px", "bSortable": false },
			{"sWidth": "25px", "bSortable": false },
			{"sWidth": "80px", "bSortable": false },
			{"sWidth": "90px", "bSortable": false },
			{"sWidth": "90px", "bSortable": false }    
	    ]
    });  
	// $('#publishedStoryTable > tbody > tr > td > a.preview').on('click',function(e){	
	// 	e.preventDefault();					
	// 	$('#previewStory .modal-data').html('<iframe height="768px" width="1366px" src="'+ $(this).prop('href')+'"></iframe>');	 			
	// 	$('#previewStory').reveal();		
	// });	
	// $('#storiesTable > tbody > tr > td > a.preview').on('click',function(e){	
	// 	e.preventDefault();					
	// 	$('#previewStory .modal-data').html('<iframe height="768px" width="1366px" src="'+ $(this).prop('href')+'"></iframe>');	 			
	// 	$('#previewStory').reveal();		
	// });	
	// $('#storiesTable > tbody > tr > td > a.publish').on('click',function(e){	
	// 	e.preventDefault();		
	// 	var a = $(this);
	// 	$.ajax
	// 	({ url: $(this).prop('href')}).done(function(d) 
	// 	{ 		
	// 		a.toggleClass('published unpublished');					 
	// 	});	 			
	// });
  $(document).on('click', '#btnReviewer', function(e){
		e.preventDefault();		
		$('#reviewerKey .modal-data').html('<iframe height="100%" width="100%" src="'+ $(this).data('link')+'"></iframe>');	 			
		$('#reviewerKey').reveal();
		return true;	
  });
  $(document).on('click', '#btnPreview', function(e){
		e.preventDefault();		
		//$('#previewStory .modal-data').html('<iframe height="100%" width="100%" src="'+ $(this).data('link')+'"></iframe>');
		var dialog = '<div><iframe style="width:100%;height:100%" src="'+ $(this).data('link')+'"></iframe></div>'	 			;
		//$('#previewStory').reveal();
			$(dialog).dialog({ resizable: true ,draggable: false,
			maxHeight: $(window).height(),
			height: $(window).height()-200,
			width: $(window).width()-200,
			modal: true,
		    open: function() {
		        $(this).dialog('option', 'maxHeight', $(window).height());
		   }});
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
				//a.toggleClass('disabled');	
				a.find('span').text(d.title)							
			});	 							
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
			 		if( secT.prev.length)
			 		{
		 			  $(secT).insertBefore($(secT).prev());
			 		}
		 		}
		 		else
		 		{
		 			subT = secT.find('ul li.sub[id='+item_id+']');
		 			if( subT.prev.length)
			 		{
		 			  $(subT).insertBefore($(subT).prev());
			 		}
		 		}	
						
			}).error(function(e){ popuper("Changing order failed.","error");});	
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
			 		if( secT.next.length)
			 		{
		 			  $(secT).insertAfter($(secT).next());
			 		}
		 		}
		 		else
		 		{
		 			subT = secT.find('ul li.sub[id='+item_id+']');
		 			if( subT.next.length)
			 		{
		 			  $(subT).insertAfter($(subT).next());
			 		}
		 		}		 				
			}).error(function(e){ popuper("Changing order failed.","error");});	
		} 	
	});
	$('.story-viewer').on("click",'#btn-up-slideshow', function() {
  
  			var secT = $(this).parents('.fields');
  			if( !secT.prev.length) return false;
		 		
			$.ajax
			({
				url: 'up_slideshow',			  
				data: {asset_id: secT.find("> input").val()},
				type: "POST",			
		        dataType: 'json'

			}).done(function(d) 
			{
				if( secT.prev.length)
		 		{
	 			   $(secT).insertBefore($(secT).prev());
		 		}				
						
			}).error(function(e){ popuper("Changing order failed.","error");});	



	});
		$('.story-viewer').on("click",'#btn-down-slideshow', function() {
			var secT = $(this).parents('.fields');
  			if( !secT.next.length) return false;
			$.ajax
			({
				url: 'down_slideshow',			  
				data: {asset_id: $(this).parents('.fields').find("> input").val()},
				type: "POST",			
		        dataType: 'json'

			}).done(function(d) 
			{
				if( secT.next.length)
		 		{
	 			  $(secT).insertAfter($(secT).next());
		 		}
						
			}).error(function(e){ popuper("Changing order failed.","error");});	



	});
	$('#btnDelete').click(function(){

	
		if(section_id == -1 ) { popuper("Nothing selected","notice"); return true;}


		var c=confirm("Item will be deleted permanently");
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
					
		}).error(function(e){ popuper("Deleting failed.","error");});

		return true;	
	});


	$('#btnAddSection').click(function(){ method = 'n';	el_type = 's';  getStory(-1,-1,1);});

	$('#btnAddItem').click(function(){	
		var temp;
		if(section_id == -1) {alert("Select section for new item"); return true;}
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
});

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
			//$('#contentPreview').html($('#contentForm #contentArticle').val());	
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
