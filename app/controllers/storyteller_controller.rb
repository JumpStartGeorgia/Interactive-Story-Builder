class StorytellerController < ApplicationController
	layout "storyteller"
  def index
  	@story = Story.fullsection(params[:id])  	
  end
end
