class ReviewController < ApplicationController
	layout false
  def index
    @story = Story.find_by_reviewer_key(params[:id])

  	if @story.present?
  	  if @story.published?
        redirect_to storyteller_show_path(@story)  	  
  	  else
        respond_to do |format|     
          format.html { render 'storyteller/index', layout: false }
        end
      end
    else
      redirect_to root_path, :notice => t('app.msgs.does_not_exist')
    end
  end
end
