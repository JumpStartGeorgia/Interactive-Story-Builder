class RootController < ApplicationController    
    before_filter :asset_filter    
  def index   
    
    @js.push("navbar.js", "magneto.js","filter.js","grid.js", "modalos.js")
    @css.push("navbar.css", "filter.css", "grid.css", "modalos.css")

    @stories = process_filter_querystring(Story.is_published_home_page.paginate(:page => params[:page], :per_page => per_page))      


    respond_to do |format|
      format.html  
      format.json { render json: @stories }
      format.js { render 'shared/grid' }
    end
  end

  def author   
    
    @author = User.find_by_permalink(params[:user_id])

    if @author.present?
      @js.push("navbar.js","magneto.js","filter.js","grid.js", "stories.js")
      @css.push("navbar.css", "filter.css", "grid.css", "stories.css")
      @stories = process_filter_querystring(Story.stories_by_author(@author.id).paginate(:page => params[:page], :per_page => per_page))      
      @editable = (user_signed_in? && current_user.id == @author.id)
      if(@editable)        
        @js.push("jquery.reveal.js")
        @css.push("reveal.css")
      end
      respond_to do |format|     
        format.html
        format.js { render 'shared/grid' }
      end    
    else
      redirect_to root_path, :notice => t('app.msgs.does_not_exist')
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
    @css.push("news.css") 
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
    @css.push("todo.css")
    respond_to do |format|
      format.html 
    end
  end

  def about    
    respond_to do |format|
      format.html 
    end
  end

  private

  def asset_filter
    @css.push("root.css")
  end 
  
end
