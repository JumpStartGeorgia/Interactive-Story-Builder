class StorytellerController < ApplicationController
	layout "storyteller"
  def index
  	@story = Story.is_published.fullsection(params[:id])  
  	if @story.present?
      respond_to do |format|     
        format.html 
      end
    else
      redirect_to root_path, :notice => t('app.msgs.not_authorized')
    end
  end
end
