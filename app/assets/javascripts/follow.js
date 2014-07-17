$(document).ready(function() {
  // register the follow link 
  if ($('.follow-link').length > 0){
    $('.follow-link').click(function(e){
      if ($(this).attr('href') != '#'){
        return;
      } else{
        e.preventDefault();

        var ths = this;
        var make_following = $(ths).attr('title') == $(ths).data('follow-title');
        var href = $(ths).data('follow-href');
        if (!make_following){
          href = $(ths).data('unfollow-href');
        }
	      $.ajax
	      ({
		      url: href,
		      data: {user_id: $(this).data('id')},
		      type: "POST",			
          dataType: 'json'
	      }).done(function(d) { 
          if (make_following){
            // was follow, change to following
            $(ths).fadeOut(150, function(){
              $(ths).attr('title', $(ths).data('unfollow-title'));
              $(ths).html($(ths).data('following'));
              $(ths).fadeIn();
              $(ths).addClass($(ths).data('css'));
            });
          }else {
            // was following, change to follow
            $(ths).fadeOut(150, function(){
              $(ths).attr('title', $(ths).data('follow-title'));
              $(ths).html($(ths).data('follow'));
              $(ths).fadeIn();
              $(ths).removeClass($(ths).data('css'));
            });
          }
	      });
      }
    });

    ///////////////////////////////////////////////////////
    // if query string process_follow is in url and == true
    // then trigger the click event
    // - this happens if user was not logged in
    // - if user is already following the author, do nothing
    //   in case they wanted to follow and forgot they already did
    ///////////////////////////////////////////////////////
    // - get the query string vars
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
      hash = hashes[i].split('=');
      vars.push(hash[0]);
      vars[hash[0]] = hash[1];
    }    
    // if process follow query string exists, continue
    if (vars['process_follow'] != undefined && vars['process_follow'].split('#')[0] == 'true'){
      // if this page has about modal, show it first before trigger follow link
      if ($('#modalos-about').length > 0 && $('a#modalAbout').length > 0){
        $('a#modalAbout').trigger('click');
      }
      // only trigger if the user is not already following!
      if ($('.follow-link').attr('title') == $('.follow-link').data('follow-title')){
        $('.follow-link').trigger('click');   
      }
    }
  
  }

});
