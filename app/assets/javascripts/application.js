// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require i18n
//= require i18n/translations
//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require jquery-ui
//= require twitter/bootstrap
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.bootstrap
//= require vendor
//= require jquery.reveal
//= require_tree .

$(document).ready(function(){
	// set focus to first text box on page
	if (gon.highlight_first_form_field){
	  $(":input:visible:enabled:first").focus();
	}

	// workaround to get logout link in navbar to work
	$('body')
		.off('click.dropdown touchstart.dropdown.data-api', '.dropdown')
		.on('click.dropdown touchstart.dropdown.data-api', '.dropdown form', function (e) { e.stopPropagation() });

});
$(document).ajaxComplete(function(event, request) {
  var msg = request.getResponseHeader('X-Message');
  var types = {'notice':'alert-info','success':'alert-success','error':'alert-error','alert':'alert-error'};
  var type = types[request.getResponseHeader("X-Message-Type")];
  if (msg && type)
  {
  	  $('.flash-message').prepend('<div class="alert '+ type +' %> fade in">' +
									'<a href="#" data-dismiss="alert" class="close">×</a>' +
									 msg +
									'</div>'); 
  }
});