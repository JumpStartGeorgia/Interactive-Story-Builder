class StorytellerController < ApplicationController
	layout false
  skip_before_filter :verify_authenticity_token
  before_filter(:only => [:staff_pick, :staff_unpick]) do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:staff_pick])
  end


  def index

  	story = Story.select('id').is_published.find_by_permalink(params[:id])
  	@story = Story.is_published.fullsection(story.id) if story.present?  
  	if @story.present?
      respond_to do |format|     
        format.html 
      end
      # record the view count
      impressionist(@story)
    else
      redirect_to root_path, :notice => t('app.msgs.does_not_exist')
    end
  end
  

  def staff_pick
  	story = Story.is_published.find_by_permalink(params[:id])
  	if story && !story.staff_pick
  	  story.staff_pick = true
  	  story.save(:validate => false)
  	end
  	
    redirect_to storyteller_show_path(story.permalink), :notice => t('app.msgs.staff_pick')
  end
  
  def staff_unpick
  	story = Story.is_published.find_by_permalink(params[:id])
  	if story && story.staff_pick
  	  story.staff_pick = false
  	  story.save(:validate => false)
  	end
  	
    redirect_to storyteller_show_path(story.permalink), :notice => t('app.msgs.staff_unpick')
  end
  
end
