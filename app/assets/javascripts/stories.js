
	var story_id = -1;
	var section_id = -1;
	var item_id = -1;
	var el_type = 's';
	var method = 'n';

$(document).ready(function() {

	$('.story-tree ul li.item').click(function() {
		item_id = -1;
		section_id = $(this).attr('id');

		$('.story-tree ul li').removeClass('active');
		$('.story-tree ul li.item[id='+section_id+']').addClass('active');
	    $(this).children('ul').toggle();
	    getStory(section_id,-1);
	    return false;
	});

	$('.story-tree ul li.item ul li.sub').click(function() {
		section_id = $(this).parent().parent().attr('id');
		item_id = $(this).attr('id');
		$('.story-tree ul li').removeClass('active');
		parent = $(this).parent().parent().addClass('active');
		$(this).parent().find('li#'+item_id).addClass('active');   		
		getStory(section_id,item_id);
	    return false;
	});


	
	$('#btnDelete').click(function(){

		var dataTemp = {'_method':'delete','section_id' : section_id, 'type':el_type };
		
		if(el_type!='s') 
		{		
			dataTemp['item_id'] = item_id;
		}
		$.ajax
		({
			url: 'content',			  
			data: dataTemp,
			type: "POST",			
	        dataType: 'json'
		}).done(function(d) 
		{
			console.log(d);
			
		}).error(function(e){console.log(e);});
		return true;	
	});

	$('#btnSave').click(function(){

		//send ajax data
		var aData = null;
		var aUrl = null;
		switch(el_type)
		{
			case 's':
				aUrl = 'new_section';
				aData = { 'section[story_id]':'1','section[type_id]':'1', 'section[title]':'New Title','section[audio_path]':''};
			break;
			case 'm':		
				var title = $('#mediaForm #mediaTitle').val();				
//				var files = $('#mediaForm #mediaItemPath').prop('files');				
				

				 var file = document.getElementById("mediaItemPath");
				     
			      /* Create a FormData instance */
			      var formData = new FormData();
			      /* Add the file */ 
			      formData.append("upload", file.files[0]);

console.log(formData);
			//	aData = {'media[section_id]' : section_id, 'item_id' : item_id, 'media[title]' : title, 'files_in' : files};
				
				if(item_id != -1)
				{
					aUrl = 'save_media';
				}
				else
				{
					aUrl = 'new_media';
				}
			break;
			case 'c':

				//var title = $('#contentForm #contentTitle').val();
				//var subtitle = $('#contentForm #contentSubTitle').val();
				//var article = $('#contentForm #contentArticle').val();	
				 

				// put validation here				
				//aData = {'content[section_id]' : section_id, 'content_id' : item_id, 'content[title]' : title, 'content[subtitle]': subtitle, 'content[content]': article};
				
				
				// if(item_id != -1)
				// {
				// 	aUrl = 'save_content';
				// }
				// else
				// {
				// 	aUrl = 'new_content';
				// }
			break;
		}
		// $.ajax
		// ({
		// 	url: aUrl,			  
		// 	data: formData,
		// 	type: "POST",
		// 	cache: false,
	 //        dataType: 'json',
	 //        processData: false, // Don't process the files
	 //        contentType: false
		// }).done(function(d) 
		// {
		// 	console.log(d);
			
		// });
		
	});

	$('#btnAddSection').click(function(){ method = 'n';	el_type = 's';  getStory(-1,-1);});

	$('#btnAddItem').click(function(){	
		var temp;
		if(section_id == -1) {alert("Select section for new item"); return true;}
		else  { temp = $('.story-tree ul li.item[id='+ section_id + ']'); }
		
		if( temp.data('type')[0] == 'c' && temp.has('ul').length==1 )
		{			
			alert("Only one content can be added to content type section");
		}
		else 
		{		
			method = 'n';				
			getStory(section_id,-1);			
		}	
	});

	

	$('#contentForm #contentArticle').change(function(){
		$('#contentPreview').html($(this).val());
	});	

	$('#btnTest').click(function(){


		 var file = document.getElementById("mediaItemPath");
		     
	      /* Create a FormData instance */
	      var formData = new FormData();
	      /* Add the file */ 
	      formData.append("image", file.files[0]);
	      formData.append("section_id",2)
		$.ajax
		({
			url: 'upload_file',			  
			data: formData,
			type: "POST",
			cache: false,
	        dataType: 'json',
	        processData: false, // Don't process the files
	        contentType: false
		}).done(function(d) 
		{
			console.log(d);
			
		});
	});	
	

});
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













function newContent()
{

	$.ajax
		({
		  url: 'new_content',
		  data: {'section_id' : section_id },
		  dataType: 'script',
	      cache: true
		  		 
		}).done(function(d) 
		{		
		});		
	return true;	
}









// $('#sectionForm #sectionAudio').click(function(){
// 		if($(this).prop('checked'))
// 			$('#sectionAudioPath').show();
// 		else $('#sectionAudioPath').hide();
// 	});



// function hideForms()
// {
// 	var view = $('.story-viewer');
// 	view.find('#sectionForm').hide();
// 	view.find('#contentForm').hide();
// 	view.find('#contentPreview').hide();
	
// 	view.find('#mediaForm').hide();	
// }

