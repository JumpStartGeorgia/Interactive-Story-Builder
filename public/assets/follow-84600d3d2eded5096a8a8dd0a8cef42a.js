$(document).ready(function(){if($(".follow-link").length>0){$(".follow-link").click(function(e){if("#"==$(this).attr("href")){e.preventDefault();var t=this,i=$(t).attr("title")==$(t).data("follow-title"),n=$(t).data("follow-href");i||(n=$(t).data("unfollow-href")),$.ajax({url:n,data:{user_id:$(this).data("id")},type:"POST",dataType:"json"}).done(function(){i?$(t).fadeOut(150,function(){$(t).attr("title",$(t).data("unfollow-title")),$(t).html($(t).data("following")),$(t).fadeIn(),$(t).addClass($(t).data("css"))}):$(t).fadeOut(150,function(){$(t).attr("title",$(t).data("follow-title")),$(t).html($(t).data("follow")),$(t).fadeIn(),$(t).removeClass($(t).data("css"))})})}});for(var e,t=[],i=window.location.href.slice(window.location.href.indexOf("?")+1).split("&"),n=0;n<i.length;n++)e=i[n].split("="),t.push(e[0]),t[e[0]]=e[1];void 0!=t.process_follow&&"true"==t.process_follow.split("#")[0]&&($("#modalos-about").length>0&&$("a#modalAbout").length>0&&$("a#modalAbout").trigger("click"),$(".follow-link").attr("title")==$(".follow-link").data("follow-title")&&$(".follow-link").trigger("click"))}});