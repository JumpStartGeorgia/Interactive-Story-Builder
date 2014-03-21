class StorytellerController < ApplicationController
	layout "storyteller"
  def index
  	@story = Story.find_by_id(params[:id])
  	logger.debug(params)  	
  end
end
