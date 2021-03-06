class ApplicationController < ActionController::Base
	require 'will_paginate/array'
  	protect_from_forgery


  PER_PAGE_COUNT = 9
  DEVISE_CONTROLLERS = ['devise/sessions', 'devise/registrations', 'devise/passwords']

	before_filter :set_locale
	before_filter :is_browser_supported?
	before_filter :preload_global_variables
	before_filter :initialize_gon
	before_filter :store_location
	after_filter :flash_to_headers


  layout :layout_by_resource


	unless Rails.application.config.consider_all_requests_local
		rescue_from Exception,
		            :with => :render_error
		rescue_from ActiveRecord::RecordNotFound,
		            :with => :render_not_found
		rescue_from ActionController::RoutingError,
		            :with => :render_not_found
		rescue_from ActionController::UnknownController,
		            :with => :render_not_found
		rescue_from ActionController::UnknownAction,
		            :with => :render_not_found

    rescue_from CanCan::AccessDenied do |exception|
      redirect_to root_url, :alert => exception.message
    end
	end

	Browser = Struct.new(:browser, :version)
	SUPPORTED_BROWSERS = [
		Browser.new("Chrome", "15.0"),
		Browser.new("Safari", "4.0.2"),
		Browser.new("Firefox", "10.0.2"),
		Browser.new("Internet Explorer", "9.0"),
		Browser.new("Opera", "11.0")
	]

	def is_browser_supported?
		user_agent = UserAgent.parse(request.user_agent)
    logger.debug "////////////////////////// BROWSER = #{user_agent}"
# 		if SUPPORTED_BROWSERS.any? { |browser| user_agent < browser }
# 			# browser not supported
# logger.debug "////////////////////////// BROWSER NOT SUPPORTED"
# 			render "layouts/unsupported_browser", :layout => false
# 		end
	end


	def set_locale
    if params[:locale] and I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
    else
      I18n.locale = I18n.default_locale
    end
	end

  def default_url_options(options={})
    { :locale => I18n.locale }
  end
  
	def preload_global_variables
    @languages = Language.sorted
    @languages_published = @languages.select{|x| x.has_published_stories == true}
		@categories = Category.sorted
    @categories_published = @categories.select{|x| x.has_published_stories == true}
    @face_id = Rails.env.production? ? ENV['STORY_BUILDER_FACEBOOK_APP_ID'] : ENV['DEV_FACEBOOK_APP_ID']        
    # for loading extra css/js files    
		@css = []
		@js = []
    
    # have to insert devise styles/js here since no controllers exist
    if params[:controller].present? && params[:controller].start_with?('devise/')
      @css.push("navbar.css")
#      @css.push('devise.css',"navbar.css")
#      @js.push('nickname.js')
    end
	end
  

	def initialize_gon
		gon.set = true
		gon.highlight_first_form_field = true

    gon.page_filtered = false       
    gon.filter_path = request.path + (params[:controller] == 'stories' ?  "/index" : "")
    gon.check_permalink = story_check_permalink_path
    gon.check_nickname = settings_check_nickname_path
    gon.nickname_duplicate = I18n.t('app.msgs.nickname_duplicate')
    gon.nickname_url = I18n.t('app.msgs.nickname_url')
    gon.story_duplicate = I18n.t('app.msgs.story_duplicate')
    gon.story_url = I18n.t('app.msgs.story_url')

    gon.msgs_select_section = I18n.t('app.msgs.select_section')
    gon.msgs_one_section_content = I18n.t('app.msgs.one_section.content')
    gon.msgs_one_section_slideshow = I18n.t('app.msgs.one_section.slideshow')
    gon.msgs_one_section_embed_media = I18n.t('app.msgs.one_section.embed_media')

		if I18n.locale == :ka
		  gon.datatable_i18n_url = "/datatable_ka.txt"
		else
		  gon.datatable_i18n_url = ""
		end
	end


  
  def layout_by_resource
    if !DEVISE_CONTROLLERS.index(params[:controller]).nil? && request.xhr?
      nil
    else
      "application"
    end
  end

  ## process the filter requests
  def process_filter_querystring(story_objects)    
    gon.page_filtered = params[:staff_pick].present? || params[:sort].present? || params[:category].present? || params[:tag].present? || params[:language].present? || params[:q].present? || params[:following].present?
    
    # not published (only available when users editing their stories)
    if params[:not_published].present?
      @story_filter_not_published = params[:not_published].to_bool
    else
  		@story_filter_not_published = false
    end
    story_objects = story_objects.is_not_published if @story_filter_not_published

    # staff pick
    if params[:staff_pick].present?
      @story_filter_staff_pick = params[:staff_pick].to_bool
    #elsif params[:sort].present? || params[:category].present? || params[:tag].present? || params[:language].present? || params[:q].present?
     # @story_filter_staff_pick = false
    else
#  		@story_filter_staff_pick = controller_action?('root','index')
  		@story_filter_staff_pick = false
    end
    story_objects = story_objects.is_staff_pick if @story_filter_staff_pick

    # sort
    @story_filter_sort_recent = true
    @story_filter_sort_permalink =  ""
    if params[:sort].present? && I18n.t('filters.sort').keys.map{|x| x.to_s}.include?(params[:sort])
      case params[:sort]
        when 'recent'
    			story_objects = story_objects.recent
        when 'reads'
    			story_objects = story_objects.reads
          @story_filter_sort_recent = false
          @story_filter_sort_permalink = "reads"
        when 'likes'
    			story_objects = story_objects.likes
          @story_filter_sort_recent = false
          @story_filter_sort_permalink = "likes"
      end
			@story_filter_sort = I18n.t("filters.sort.#{params[:sort]}")
    else
      story_objects = story_objects.recent
			@story_filter_sort = I18n.t("filters.sort.recent")
    end
    
    # category
    @story_filter_category_all = true
    @story_filter_category_permalink =  ""
    index = params[:category].present? ? @categories_published.index{|x| x.permalink.downcase == params[:category].downcase} : nil
    if index.present?
      story_objects = story_objects.by_category(@categories_published[index].id)    
  		@story_filter_category = @categories_published[index].name
      @story_filter_category_permalink =  @categories_published[index].permalink
      @story_filter_category_all = false
    else
  		@story_filter_category = I18n.t("filters.all")
    end
    
    #tags
    if params[:tag].present?
      story_objects = story_objects.tagged_with(params[:tag])
  		@story_filter_tag = params[:tag].titlecase
    else
  		@story_filter_tag = I18n.t("filters.all")
    end    
    
    # language
    @story_filter_language_permalink =  ""
    index = params[:language].present? ? @languages_published.index{|x| x.locale.downcase == params[:language].downcase} : nil
#    if index.nil? && user_signed_in? && current_user.default_story_locale.present?
#      index = @languages_published.index{|x| x.locale.downcase == current_user.default_story_locale}
#    end
    @story_filter_language_all = true
    if index.present?
      story_objects = story_objects.by_language(@languages_published[index].locale)    
  		@story_filter_language = @languages_published[index].name
      @story_filter_language_permalink = @languages_published[index].locale
      @story_filter_language_all = false
    else
  		@story_filter_language = I18n.t("filters.all")
    end
    
    # following users
    @story_filter_show_following = user_signed_in? && controller_action?('root','index')
    if user_signed_in?
      @following_users = current_user.following_users
      if @following_users.present? && params[:following].present? && params[:following].to_bool == true
        story_objects = story_objects.by_authors(@following_users.map{|x| x.id}.uniq)
        @story_filter_following = true
      else 
        @story_filter_following = false
      end
    end
     # logger.debug "/////////////////// @story_filter_following = #{@story_filter_following}"
        
    # search
    @q = ""
		if params[:q].present?
			story_objects = story_objects.search_for(params[:q])
			gon.q = params[:q]
      @q = params[:q]
		end
    return story_objects
  end

  # after user logs in go back to the last page or go to root page
	def after_sign_in_path_for(resource)
		session[:previous_urls].last || request.env['omniauth.origin'] || root_path(:locale => I18n.locale)
	end

  def valid_role?(role)
    redirect_to root_path, :notice => t('app.msgs.not_authorized') if !current_user || !current_user.role?(role)
  end

	# store the current path so after login, can go back
	def store_location

		session[:previous_urls] ||= []
		# only record path if page is not for users (sign in, sign up, etc) and not for reporting problems
		if session[:previous_urls].first != request.fullpath && 
        params[:format] != 'js' && params[:format] != 'json' && !request.xhr? &&
        request.fullpath.index("/users/").nil?
			session[:previous_urls].unshift request.fullpath
    elsif session[:previous_urls].first != request.fullpath &&
       request.xhr? && !request.fullpath.index("/users/").nil? &&
       params[:return_url].present?
      session[:previous_urls].unshift params[:return_url]
		end

		session[:previous_urls].pop if session[:previous_urls].count > 1
    #Rails.logger.debug "****************** prev urls session = #{session[:previous_urls]}"
	end


  # add in required content for translations if none provided
  # - if default locale does not have translations, use first trans that does as default
  def add_missing_translation_content(ary_trans)
    if ary_trans.present?
      default_trans = ary_trans.select{|x| x.locale == I18n.default_locale.to_s}.first
  
      if default_trans.blank? || !default_trans.required_data_provided?
        # default locale does not have data so get first trans that does have data
        ary_trans.each do |trans|
          if trans.required_data_provided?
            default_trans = trans
            break
          end
        end
      end

      if default_trans.present? && default_trans.required_data_provided?
        ary_trans.each do |trans|
          if trans.locale != default_trans.locale && !trans.required_data_provided?
            # add required content from default locale trans
            trans.add_required_data(default_trans)
          end
        end
      end
    end
  end

  def permalink_normalize(str)
    unless str.blank?
      n = str.mb_chars.downcase.to_s.strip.latinize.to_ascii
      n.gsub!(/\s+/,            '-')
      n.gsub!(/[^[:alnum:]_\-]/, '')
      n.gsub!(/-{2,}/,          '-')
      n.gsub!(/^-/,             '')
      n.gsub!(/-$/,             '')
      n
    end
  end

  #######################
	def render_not_found(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
		render :file => "#{Rails.root}/public/404.html", :status => 404
	end

	def render_error(exception)
		ExceptionNotifier::Notifier
		  .exception_notification(request.env, exception)
		  .deliver
		render :file => "#{Rails.root}/public/500.html", :status => 500
	end

 def flash_to_headers 	
      return unless request.xhr?
      response.headers['X-Message'] = flash_message
      response.headers["X-Message-Type"] = flash_type.to_s

      flash.discard # don't want the flash to appear when you reload page
    end
  def per_page
    return PER_PAGE_COUNT
  end
private

	def flash_message
	   [:success, :error, :notice, :alert, nil].each do |type|
	     return "" if type.nil?
	     return flash[type] unless flash[type].blank?
	   end
	end

	def flash_type
	   [:success, :error, :notice, :alert, nil].each do |type|
	       return "" if type.nil?
	       return type unless flash[type].blank?
	   end
	end
  def controller?(name)
   return params[:controller] == name
  end
  def action?(name)
   return params[:action] == name
  end
  def controller_action?(controller_name, action_name)
   return params[:controller] == controller_name && params[:action] == action_name
  end

end
