class RootController < ApplicationController

  def index    

    @stories = Story.is_published.order("published_at desc").limit(10)

    @about_text = 'Story builder allows anyone with text, pictures and/or videos to combine this content into a creative story that can be published and shared with the world.'

    respond_to do |format|
      format.html  #index.html.erb
      format.json { render json: @stories }
    end
  end


end
