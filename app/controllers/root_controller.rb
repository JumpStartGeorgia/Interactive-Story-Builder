class RootController < ApplicationController

  def index    

    @stories = Story.is_published.order("published_at desc").limit(10)

    @about_text = 'Story builder allows anyone with text, pictures and/or videos to combine this content into a creative story that can be published and shared with the world.'

    @news = News.published.limit(2)

    respond_to do |format|
      format.html  #index.html.erb
      format.json { render json: @stories }
    end
  end


  def news
    @news = News.published
  
    respond_to do |format|
      format.html  #index.html.erb
      format.json { render json: @news }
    end
  end
  
  def feedback
    @message = Message.new

    @message_types = []
    Message::TYPE.each{|k,v| @message_types << [I18n.t("message_types.#{k}"), v]} 
    @message_types.sort_by!{|x| x[0]}

    if request.post?
		  @message = Message.new(params[:message])
		  if @message.valid?
		    # send message
				ContactMailer.new_message(@message).deliver
				@email_sent = true
		  end
	  end
    respond_to do |format|
      format.html 
    end
  end

  

end
