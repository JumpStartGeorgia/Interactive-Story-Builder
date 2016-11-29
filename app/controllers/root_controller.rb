class RootController < ApplicationController
  def index

    @js.push("navbar.js", "zeroclipboard.min.js","filter.js")
    @css.push("navbar.css", "filter.css", "grid.css","root.css")
    @stories = process_filter_querystring(Story.is_not_deleted.is_published_home_page.paginate(:page => params[:page], :per_page => per_page))
    @navbar_invisible = true
    respond_to do |format|
      format.html
      #format.json { render json: @stories }
      format.json { render :json => {:d => render_to_string("shared/_grid", :formats => [:html], :layout => false)}}
    end
  end
  def author
    @author = User.find_by_permalink(params[:user_id])

    if @author.present?
      @js.push("zeroclipboard.min.js", "filter.js","stories.js","follow.js")
      @css.push("navbar.css", "filter.css", "grid.css", "stories.css", "author.css")
      @stories = process_filter_querystring(Story.is_not_deleted.stories_by_author(@author.id).paginate(:page => params[:page], :per_page => per_page))
      @editable = (user_signed_in? && current_user.id == @author.id)

      @is_following = Notification.already_following_user(current_user.id, @author.id) if user_signed_in?

      # if(@editable)
      #   @js.push("modalos.js")
      #   @css.push("modalos.css")
      # end
      respond_to do |format|
        format.html
        format.json { render :json => {:d => render_to_string("shared/_grid", :formats => [:html], :layout => false)}}
      end
    else
      redirect_to root_path, :notice => t('app.msgs.does_not_exist')
    end
  end

  def embed
    @story = Story.is_not_deleted.is_published.find_by_permalink(params[:story_id])

    respond_to do |format|
      if @story.present?
        if params[:type] == 'full'
          @is_embed = true
          @no_nav = true
          @css.push("navbar.css", "navbar2.css", "storyteller.css", "modalos.css")
          @js.push("storyteller.js","modalos.js", "follow.js")

          impressionist(@story, :unique => [:session_hash]) # record the view count
          @story.reload

          @story.sections.includes([:media,:content,:embed_medium,:youtube,:slideshow])

          # record if the user has liked this story
          @user_likes = false
          @user_likes = current_user.voted_up_on? @story if user_signed_in?

          format.html { render 'storyteller/index', :layout => false }
        else
          format.html { render 'embed', layout: false }
        end
      else
        format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
      end
    end
  end

  def demo
    @story = Story.is_not_deleted.demo
  	if @story.present?
      redirect_to storyteller_show_path(@story.permalink)
      # respond_to do |format|
      #   format.html { render 'storyteller/index' }
      # end
    else
      redirect_to root_path, :notice => t('app.msgs.does_not_exist')
    end
  end

  def news
    @css.push("news.css","navbar.css")
    @news = News.published
    respond_to do |format|
      format.html  #index.html.erb
      format.json { render json: @news }
    end
  end

  def news_show
    @css.push("news.css","navbar.css")
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
    @css.push("navbar.css")
    @message = Message.new(:mailer_type => Message::MAILER_TYPE[:feedback])

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
    @css.push("todo.css","navbar.css")

    @page = Page.by_name('todo')

    if @page.present?
      respond_to do |format|
        format.html
      end
    else
		  flash[:info] =  t('app.msgs.does_not_exist')
		  redirect_to root_path(:locale => I18n.locale)
		  return
	  end
  end

  def about
    @css.push("navbar.css","about.css")
    respond_to do |format|
      format.html
    end
=begin
    @page = Page.by_name('about')

    if @page.present?
      respond_to do |format|
        format.html
      end
    else
		  flash[:info] =  t('app.msgs.does_not_exist')
		  redirect_to root_path(:locale => I18n.locale)
		  return
	  end
=end
  end

  def feed
    index = params[:category].present? ? @categories_published.index{|x| x.permalink.downcase == params[:category].downcase} : nil
    @items =  Story.is_not_deleted.is_published_home_page.include_categories.recent
    @filtered_by_category = ""
    if index.present?
      @filtered_by_category = @categories_published[index].permalink
      @items = @items.by_category(@categories_published[index].id)
    end
   @filtered_by_tag = ""
   if params[:tag].present?
      @filtered_by_tag = params[:tag]
      @items =  @items.tagged_with(params[:tag])
    end
    @filter_by = ""
    @filter_by = ("category = " + @filtered_by_category + (@filtered_by_tag.present? ? ", " : "")) if @filtered_by_category.present?
    @filter_by += "tag = " + @filtered_by_tag  if @filtered_by_tag.present?
    @filter_by = "nothing" if @filter_by.empty?

    respond_to do |format|
      format.atom { render :layout => false }
    end
  end

end
