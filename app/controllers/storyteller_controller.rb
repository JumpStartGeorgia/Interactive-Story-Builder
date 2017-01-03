class StorytellerController < ApplicationController
	layout false
  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_user!, :except => [:index, :record_comment]
  before_filter(:only => [:staff_pick, :staff_unpick]) do |controller_instance|
    controller_instance.send(:valid_role?, User::ROLES[:staff_pick])
  end


  def index
    sl = params[:sl]
    if sl.present? && I18n.locale.to_s != sl && I18n.available_locales.index(sl.to_sym)
      params.delete(:sl)
      redirect_to storyteller_show_path(params.merge({ locale: sl})), :notice => t('app.msgs.redirected_with_app_locale')
    else

      @story = Story.with_translations(I18n.locale).is_published.find_by_permalink(params[:id])

      if @story.present?
        @story.set_to_app_locale

# logger.debug "@@@@@@@@@@@@@@@@@@@@@@@@@"
# logger.debug "app locale = #{I18n.locale}; story locale = #{@story.current_locale}"        

        impressionist(@story, :unique => [:session_hash]) # record the view count
        @story.reload
        @story.set_to_app_locale

        @story.sections.includes([:media,:content,:embed_medium,:youtube,:slideshow])

        @stories = @story.random_related_stories

# logger.debug "after reload app locale = #{I18n.locale}; story locale = #{@story.current_locale}"        
# logger.debug "@@@@@@@@@@@@@@@@@@@@@@@@@"


        # record if the user has liked this story
        @user_likes = false
        @user_likes = current_user.voted_up_on? @story if user_signed_in?
        @is_following = Notification.already_following_user(current_user.id, @story.author_ids) if user_signed_in?

        @no_nav = true if params[:n] == 'n'

        @css.push("navbar.css", "navbar2.css", "storyteller.css", "modalos.css", "grid2.css")
        @js.push("storyteller.js","modalos.js","follow.js")

        respond_to do |format|
          format.html
        end

      else
        redirect_to root_path, :notice => t('app.msgs.does_not_exist')
      end
    end
  end


  def staff_pick
  	story = Story.is_published.find_by_permalink(params[:id])
  	if story.present? && !story.staff_pick
  	  story.staff_pick = true
  	  story.save(:validate => false)
  	end

    respond_to do |format|
      format.json { render json: nil , status: :created }
    end
  end

  def staff_unpick
  	story = Story.is_published.find_by_permalink(params[:id])
  	if story.present? && story.staff_pick
  	  story.staff_pick = false
  	  story.save(:validate => false)
  	end

    respond_to do |format|
      format.json { render json: nil , status: :created }
    end
  end


  def like
    story = Story.is_published.find_by_permalink(params[:id])
    story.liked_by current_user if story.present?

    respond_to do |format|
      format.json { render json: nil , status: :created }
    end

  end


  def unlike
    story = Story.is_published.find_by_permalink(params[:id])
    story.unliked_by current_user if story.present?

    respond_to do |format|
      format.json { render json: nil , status: :created }
    end
  end

  def record_comment
    story = Story.is_published.find_by_permalink(params[:id])
    story.increment_comment_count if story.present?

    respond_to do |format|
      format.json { render json: {count: story.present? ? story.comments_count : 0} , status: :created }
    end
  end

end
