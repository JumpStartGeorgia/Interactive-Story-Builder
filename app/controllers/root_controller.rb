class RootController < ApplicationController

  def index    

    @stories = Story.is_published.order("published_at desc").paginate(:page => params[:page], :per_page => 9)


    @news = News.published.limit(2)

    respond_to do |format|
      format.html  #index.html.erb
      format.json { render json: @stories }
    end
  end

  def demo
    @story = Story.demo

  	if @story.present?
      respond_to do |format|     
        format.html { render 'storyteller/index', layout: false }
      end
    else
      redirect_to root_path, :notice => t('app.msgs.does_not_exist')
    end
  end
  


  def news
    @news = News.published
  
    respond_to do |format|
      format.html  #index.html.erb
      format.json { render json: @news }
    end
  end
  
  def news_show
    @news = News.find_by_permalink(params[:id])

		if @news.present?
      respond_to do |format|
        format.html  #index.html.erb
        format.json { render json: @news }
      end
		else
			flash[:info] =  t('app.msgs.does_not_exist')
			redirect_to root_path(:locale => I18n.locale)
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

  def todo_list
    respond_to do |format|
      format.html 
    end
  end
  

end
