class RootController < ApplicationController

  def index    
    @stories = Story.where(:published => 1).order("published_at desc").limit(10)

    respond_to do |format|
      format.html  #index.html.erb
      format.json { render json: @stories }
    end
  end


end
