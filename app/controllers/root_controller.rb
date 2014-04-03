class RootController < ApplicationController

  def index    
    @stories = Story.where(:published => 1)

    respond_to do |format|
      format.html  #index.html.erb
      format.json { render json: @stories }
    end
  end


end
