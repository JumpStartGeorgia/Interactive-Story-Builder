class StorytellerController < ApplicationController
	layout false
  skip_before_filter:verify_authenticity_token
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
end
