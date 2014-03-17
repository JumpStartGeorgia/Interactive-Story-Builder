
/*$(document).ready(function() {
	
    //$('#storiesTable').dataTable();

	  var map = L.map('map',{scrollWheelZoom: false, zoom:13, center: L.LatLng(41.703656435,44.7840714455)}).setView([41.69,44.80], 14);

	// add an OpenStreetMap tile layer
	L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
	    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
	}).addTo(map);

	// add a marker in the given location, attach some popup content to it and open the popup
	L.marker([51.5, -0.09]).addTo(map)
	    .bindPopup('A pretty CSS3 popup. <br> Easily customizable.')
	    .openPopup();

	//    alert(<%= story.title %>);
});

*/
	var story_id = -1;
	var section_id = -1;
	var item_id = -1;
	var el_type = 'section';
	var method = 'new';

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
		$.ajax
		({
			url: 'destroy_item',			  
			data: {'_method':'delete','type':'c','id':'5'},
			type: "POST",
			cache: false,
	        dataType: 'json',	        
		}).done(function(d) 
		{
			console.log(d);
			
		});
	});
	$('#btnSave').click(function(){

		//send ajax data
		var aData = null;
		var aUrl = null;
		switch(el_type)
		{
			case 'section':
				aUrl = 'new_section';
				aData = { 'section[story_id]':'1','section[type_id]':'1', 'section[title]':'New Title','section[audio_path]':''};
			break;
			case 'media':		
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
			case 'content':

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

	$('#btnAddSection').click(function(){	
		getStory(-1,-1);
		$('.story-viewer #sectionForm').show();
	});

	$('#btnAddItem').click(function(){	
		if(section_id == -1) alert("Select section for new item");
		else 
		{
			hideForms();
		//	clearContentForm();
			method = 'new';
			if(el_type == 'content')
			{
				fillContent();
				$('.story-viewer #contentForm').show();
				$('.story-viewer #contentPreview').show();
			}
			else 
			{
				$('.story-viewer #mediaForm').show();
			}
		}	
	});

	$('#sectionForm #sectionAudio').click(function(){
		if($(this).prop('checked'))
			$('#sectionAudioPath').show();
		else $('#sectionAudioPath').hide();
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
		selectedSection = $('.story-tree ul li.item[id='+ id + ']');
		el_type = selectedSection.data('type');	
	}
	
	hideForms();

	if(subid != -1)
	{				
	
		if(el_type == 'content')
		{

			method = 'save';

			$('.story-viewer #contentForm').show();
			$('.story-viewer #contentPreview').show();
			//col.find('#columnTitle').val(selectedSection.find('ul li.sub[id='+subid+'] span').text());
			fillContent();
		}
		else 
		{
			$('.story-viewer #mediaForm').show();	
			fillMedia();

		}
	}
	else if(id != -1)
	{		
		fillSection();			
		$('.story-viewer #sectionForm').show();
		//$('.story-viewer').html(selectedSection.find('span').text());	
	}
	else
	{
		item_id = -1;
		section_id = -1;
		$('.story-tree ul li').removeClass('active');
		el_type = 'section'; 

	}
}
function hideForms()
{
	var view = $('.story-viewer');
	view.find('#sectionForm').hide();
	view.find('#contentForm').hide();
	view.find('#contentPreview').hide();
	
	view.find('#mediaForm').hide();	
}



function fillSection()
{	
	$.ajax
		({
		  url: 'get_section',
		  data: {'section_id' : section_id, 's':method },
		  dataType: 'script',
	      cache: true
		});


		// .done(function(d) 
		// {
		// 	if(d != null)
		// 	{
		// 		$('#sectionForm #sectionType > option[value="'+d.type_id+'"]').prop('selected', true);
		// 		$('#sectionForm #sectionTitle').attr("value", d.title);	
		// 		$('#sectionForm #sectionAudio').prop('checked', d.audio_path != null ? true : false);
		// 		$('#sectionForm #sectionAudioPathLabel').text("asdf");
		// 		if(d.audio_path != null) $('#sectionAudioPath').show();
		// 		else $('#sectionAudioPath').hide();
		// 	}				
		// });			
	return true;	
}
function newContent()
{

	//clearContentForm();
	$.ajax
		({
		  url: 'new_content',
		  data: {'section_id' : section_id },
		  dataType: 'script',
	      cache: true
		  		 
		}).done(function(d) 
		{
			console.log(d);
			// if(d != null)
			// {
			// 	console.log(d);
			// 	$('#contentForm #contentTitle').val(d.title);
			// 	$('#contentForm #contentSubTitle').val(d.subtitle);
			// 	$('#contentForm #contentArticle').val(d.content);	
			// 	$('#tinemcePreview').html(d.content)						
			// }				
		});		
	return true;	
}
function fillContent()
{

	//clearContentForm();
	$.ajax
		({
		  url: 'get_content',
		  data: {'section_id' : section_id, 's':method, 'item_id' : item_id },
		  dataType: 'script',
	      cache: true
		  		 
		}).done(function(d) 
		{
			console.log(d);
			// if(d != null)
			// {
			// 	console.log(d);
			// 	$('#contentForm #contentTitle').val(d.title);
			// 	$('#contentForm #contentSubTitle').val(d.subtitle);
			// 	$('#contentForm #contentArticle').val(d.content);	
			 	$('#contentPreview').html($('#contentForm #contentArticle').val());					
			// }				
		});		
	return true;	
}
function fillMedia()
{

	//clearMediaForm();
	$.ajax
		({
		 url: 'get_media',
		  data: {'section_id' : section_id, 's':method, 'item_id' : item_id },
		  dataType: 'script',
	      cache: true
		});		
	return true;	
}