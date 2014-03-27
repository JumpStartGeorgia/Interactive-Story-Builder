
	var story_id = -1;
	var section_id = -1;

	var item_id = -1;
	var el_type = 's';
	var method = 'n';

$(document).ready(function() {

	$('.story-tree ul').on('click','li.item',function() {
		item_id = -1;
		section_id = $(this).attr('id');

		$('.story-tree ul li').removeClass('active');
		$('.story-tree ul li.item[id='+section_id+']').addClass('active');
	    $(this).children('ul').toggle();
	    $('.flash-message').empty();
	    
	    getStory(section_id,-1);
	    return false;
	});

	$('.story-tree ul li.item').on('click','ul li.sub',function() {
		section_id = $(this).parent().parent().attr('id');
		item_id = $(this).attr('id');
		$('.story-tree ul li').removeClass('active');
		parent = $(this).parent().parent().addClass('active');
		$(this).parent().find('li#'+item_id).addClass('active');   
		$('.flash-message').empty();	
		
		
		getStory(section_id,item_id);
	    return false;
	});
	$('.story-viewer').on('change','#mediaType',function(){
		if($(this).val()==1) $('#mediaVideoBox').hide();
		else  $('#mediaVideoBox').show();
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
			{ "bSortable": true },	      	      
			{ "bSortable": false },
			{ "bSortable": false },
			{ "bSortable": false },
			{ "bSortable": false }
	    ]
    });  
	$('#storiesTable > tbody > tr > td > a.preview').on('click',function(e){	
		e.preventDefault();					
		$('#previewStory .modal-data').html('<iframe height="768px" width="1366px" src="'+ $(this).prop('href')+'"></iframe>');	 			
		$('#previewStory').reveal();		
	});	

	$('#btnDelete').click(function(){

		var c=confirm("Item will be deleted permanently");
		if (!c) return true;
		  
		if(section_id == -1 ) { popuper("Nothing selected","notice"); return true;}
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
				secT.find('ul li.sub[id='+item_id+']').parent().remove();		
			}
			else 
			{	
				secT.remove();		
			}
			section_id = -1;
			item_id = -1;
			$('.story-viewer').html('');
			$("html, body").animate({ scrollTop: 0 }, "slow");
					
		}).error(function(e){ popuper("Deleting failed.","error");});

		return true;	
	});
	$('#btnPreview').click(function(){					
		$('#previewStory .modal-data').html('<iframe height="768px" width="1366px" src="'+ $(this).data('storyteller')+'"></iframe>');	 			
		$('#previewStory').reveal();
		return true;	
	});

	$('#btnAddSection').click(function(){ method = 'n';	el_type = 's';  getStory(-1,-1);});

	$('#btnAddItem').click(function(){	
		var temp;
		if(section_id == -1) {alert("Select section for new item"); return true;}
		else  { temp = $('.story-tree ul li.item[id='+ section_id + ']'); }
		
		var tempType = temp.data('type')[0];
		if( tempType == 'c' && temp.has('ul').length==1 )
		{			
			alert("Only one content can be added to content type section");
		}
		else 
		{		
			method = 'n';
			el_type = tempType;				
			getData();
		}	
	});
});

function treeAdd(id, subid)
{

}
function treeDelete(id, subid)
{
	
}
function getStory(id , subid)
{
	if(id != -1)
	{
		var selectedSection = $('.story-tree ul li.item[id='+ id + ']');
		el_type = selectedSection.data('type')[0];	
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
		getData();
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