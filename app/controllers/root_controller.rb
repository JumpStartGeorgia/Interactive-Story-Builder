class RootController < ApplicationController
  def index

    @js.push("filter.js")
    @css.push("navbar.css", "filter.css", "grid.css","root.css")
    p = (request.xhr? ? params[:page] : 1)
    @stories = process_filter_querystring(Story.is_published.in_published_theme).with_translations(I18n.locale).paginate(:page => p, :per_page => per_page)
    @theme = Theme.for_homepage


    @stories_for_slider = @theme.featured_stories.with_translations(I18n.locale) if @theme.present?
    @navbar_invisible = false
    respond_to do |format|
      format.html
      format.json { render :json => {:d => render_to_string("shared/_grid", :formats => [:html], :layout => false)}}
    end
  end


  def author
    @author = Author.find_by_permalink(params[:user_id])

    if @author.present?
      @js.push("filter.js","stories.js","follow.js")
      @css.push("navbar.css", "filter.css", "grid.css", "stories.css", "author.css")
      @stories = process_filter_querystring(Story.by_authors(@author.id).in_published_theme).with_translations(I18n.locale).paginate(:page => params[:page], :per_page => per_page)
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
    sl = params[:sl]
    if sl.present? && I18n.locale.to_s != sl && I18n.available_locales.index(sl.to_sym)
      params.delete(:sl)
      redirect_to embed_path(params.merge({ locale: sl})), :notice => t('app.msgs.redirected_with_app_locale')
    else
      @story = Story.with_translations(I18n.locale).is_published.in_published_theme.find_by_permalink(params[:story_id])

      respond_to do |format|
        if @story.present?
          @story.set_to_app_locale

          if params[:type] == 'full'
            @is_embed = true
            @no_nav = true
            @css.push("navbar.css", "navbar2.css", "storyteller.css", "modalos.css")
            @js.push("storyteller.js","modalos.js", "follow.js")

            impressionist(@story, :unique => [:session_hash]) # record the view count
            @story.reload
            @story.set_to_app_locale

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
  end

  def theme
    @js.push("filter.js")
    @css.push("navbar.css", "filter.css", "grid.css","root.css")
    @theme = Theme.published.with_stories.find_by_permalink(params[:id])

    if @theme.present?
      @stories = process_filter_querystring(Story.is_published.in_published_theme.by_theme(@theme.id)).with_translations(I18n.locale).paginate(:page => params[:page], :per_page => per_page)
      @stories_for_slider = @theme.featured_stories.with_translations(I18n.locale)

      respond_to do |format|
        format.html
        format.json { render :json => {:d => render_to_string("shared/_grid", :formats => [:html], :layout => false)}}
      end
    else
      redirect_to root_path#, :notice => t('app.msgs.does_not_exist')
    end
  end

  def story_type
    @story_type = StoryType.find_by_permalink(params[:id])

    if @story_type.present?
      respond_to do |format|
        format.html
        #format.json { render json: @stories }
        format.json { render :json => {:d => render_to_string("shared/_grid", :formats => [:html], :layout => false)}}
      end
    else
      redirect_to root_path, :notice => t('app.msgs.does_not_exist')
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


  def about
    @css.push("navbar.css", "about.css")

    @page = Page.by_name('about')
    @partners = Logo.partners.sorted.active
    @sponsors = Logo.sponsors.sorted.active


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

  def feed
    index = params[:category].present? ? @categories_published.index{|x| x.permalink.downcase == params[:category].downcase} : nil
    @items = Story.with_translations(I18n.locale).is_published.in_published_theme.recent
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
