class SettingsController < ApplicationController
  before_filter :authenticate_user!, :except => [:check_nickname]
  before_filter :asset_filter


  def index
    @css.push("devise.css", "bootstrap-select.min.css","navbar.css")
    @js.push("nickname.js", "bootstrap-select.min.js")

    if request.put?
      if current_user.update_attributes(params[:user])
        flash[:notice] = I18n.t('app.msgs.success_settings')
      else
        flash[:error] = I18n.t('app.msgs.error_updated', obj:User.model_name.human, err:current_user.errors.full_messages.to_sentence)            
      end
    end

    if !current_user.local_avatar.present? 
      current_user.build_local_avatar(:asset_type => Asset::TYPE[:user_avatar])
    end      
    
    respond_to do |format|     
      format.html 
    end
  end
    
    
  def remove_avatar
    if current_user.has_provider_avatar? && current_user.local_avatar_exists?
      current_user.local_avatar = nil
      current_user.save
    end

    flash[:notice] = I18n.t('app.msgs.success_remove_avatar')

    redirect_to settings_path  
  end   
  
  def check_nickname
    output = {:permalink => nil, :is_duplicate => false}
    if params[:nickname].present?
      nickname = ActionController::Base.helpers.strip_links(params[:nickname])
      permalink_temp = permalink_normalize(nickname)
      if user_signed_in? && current_user.permalink == permalink_temp
logger.debug "************** nickname is the same!"
        output[:permalink] = current_user.permalink
      else
        u = User.new(:nickname => nickname)
logger.debug "************** nickname start: #{u.nickname}"
        u.generate_permalink
logger.debug "************** nickname after generate: #{u.nickname}"
        output = {:permalink => u.permalink, :is_duplicate => u.is_duplicate_permalink?}
      end
    end
          
    respond_to do |format|     
      format.json { render json: output } 
    end
  end 
  

  # register the current user as wanting to follow the user passed in
  def follow_user
    output = ''
    if params[:user_id].present?
      x = Notification.add_follow_user(current_user.id, params[:user_id])
      if x
        output = 'success!'
      else
        output = "error: #{x.errors.full_message}"
      end
    else
      output = 'please provide a user to follow'
    end

    respond_to do |format|     
      format.json { render json: output.to_json } 
    end
  end

  def unfollow_user
    output = ''
    if params[:user_id].present?
      x = Notification.delete_follow_user(current_user.id, params[:user_id])
      if x
        output = 'success!'
      else
        output = "error: #{x.errors.full_message}"
      end
    else
      output = 'please provide a user to follow'
    end

    respond_to do |format|     
      format.json { render json: output.to_json } 
    end
  end

  
  
  # view invitations that are currently on record for this user
  def invitations
    @invitations = Invitation.pending_by_user(current_user.id)
    
    respond_to do |format|     
      format.html 
    end
  end  

  # accept the invitation that has the key in the url
  def accept_invitation
    accepted = false
    inv = Invitation.find_by_key(params[:key])
    
    if inv.present?
      s = Story.find_by_id(inv.story_id)
      if inv.accepted_at.blank?
        if s.present?
          s.users << current_user
          inv.accepted_at = Time.now
          inv.save
          redirect_to stories_path, :notice => t('app.msgs.invitation.accepted', :title => s.title)
          accepted = true
        end
      else
        redirect_to stories_path, :notice => t('app.msgs.invitation.accepted_already', :title => s.title)
        accepted = true
      end
    end

    if !accepted
      redirect_to settings_invitations_path, :notice => t('app.msgs.invitation.bad')  
    end
  end  

  # delete the invitation that has the key in the url
  def decline_invitation
    deleted = false
    inv = Invitation.find_by_key(params[:key])
    
    if inv.present?
      inv.destroy
      deleted = true
      redirect_to settings_invitations_path, :notice => t('app.msgs.invitation.declined')
    end

    if !deleted
      redirect_to settings_invitations_path, :notice => t('app.msgs.invitation.bad')  
    end
  end  
  
  
  def notifications
		gon.notifications = true
    @css.push("bootstrap-select.min.css")
    @js.push("bootstrap-select.min.js")

		msg = []
		if request.post?
			if params[:enable_notifications].to_s.to_bool == true
				# make sure user is marked as wanting notifications
				if !current_user.wants_notifications
					current_user.wants_notifications = true
					current_user.save
					msg << I18n.t('app.msgs.notification.yes')
				end

				# language
				if params[:language]
					current_user.notification_language = params[:language]
					current_user.save
					msg << I18n.t('app.msgs.notification.language', :language => t("app.language.#{params[:language]}"))
				end

				# process news notifications
				if params[:news].present?
					# delete anything on file first
					Notification.where(:notification_type => Notification::TYPES[:published_news],
																					:user_id => current_user.id).delete_all

					if params[:news][:wants].to_s.to_bool == true
						Notification.create(:notification_type => Notification::TYPES[:published_news],
																						:user_id => current_user.id)

						msg << I18n.t('app.msgs.notification.news_yes')
					else
						msg << I18n.t('app.msgs.notification.news_no')
					end
				end

        # process story notifications
				if params[:stories_all]
					# all notifications
					# delete anything on file first
					Notification.where(:notification_type => Notification::TYPES[:published_story],
																					:user_id => current_user.id).delete_all
					# add all option
					Notification.create(:notification_type => Notification::TYPES[:published_story],
																					:user_id => current_user.id)

					msg << I18n.t('app.msgs.notification.new_story_all_success')
				elsif params[:stories_categories].present?
					# by category
					# delete anything on file first
					Notification.where(:notification_type => Notification::TYPES[:published_story],
																					:user_id => current_user.id).delete_all
					# add each category
					params[:stories_categories].each do |cat_id|
						Notification.create(:notification_type => Notification::TYPES[:published_story],
																						:user_id => current_user.id,
																						:identifier => cat_id)
					end
					msg << I18n.t('app.msgs.notification.new_story_by_category_success',
						:categories => @categories.select{|x| params[:stories_categories].index(x.id.to_s)}.map{|x| x.name}.join(", "))
				else
					# delete all notifications
					Notification.where(:notification_type => Notification::TYPES[:published_story],
																					:user_id => current_user.id).delete_all
					msg << I18n.t('app.msgs.notification.new_story_none_success')
        end

				# process story comment notifications
				if params[:story_comment].present?
					# delete anything on file first
					Notification.where(:notification_type => Notification::TYPES[:story_comment],
																					:user_id => current_user.id).delete_all

					if params[:story_comment][:wants].to_s.to_bool == true
						Notification.create(:notification_type => Notification::TYPES[:story_comment],
																						:user_id => current_user.id)

						msg << I18n.t('app.msgs.notification.story_comments_yes')
					else
						msg << I18n.t('app.msgs.notification.story_comments_no')
					end
				end

				# process following notifications
				if params[:following].present?
					existing = Notification.where(:notification_type => Notification::TYPES[:published_story_by_author],
																					:user_id => current_user.id)
          if existing.present?
  					params[:following].keys.each do |follow_user_id|
						  if params[:following][follow_user_id][:wants].to_s.to_bool == false 
                existing.select{|x| x.identifier.to_s == follow_user_id.to_s}.each do |notification|
                  notification.delete
                end

							  msg << I18n.t('app.msgs.notification.following_no',
								  :nickname => params[:following][follow_user_id][:nickname])
              end
						end
					end
				end

			else
				# indicate user does not want notifications
				if current_user.wants_notifications
					current_user.wants_notifications = false
					current_user.save
				end

				# delete any on record
				Notification.where(:notification_type => Notification::TYPES[:published_story],
																				:user_id => current_user.id).delete_all

				msg << I18n.t('app.msgs.notification.no')
			end
		end

		# see if user wants notifications
		@enable_notifications = current_user.wants_notifications
		gon.enable_notifications = @enable_notifications

		# get the notfification language
		@language = current_user.notification_language.nil? ? I18n.default_locale.to_s : current_user.notification_language

		# get new story data to load the form
		@story_notifications = Notification.where(:notification_type => Notification::TYPES[:published_story],
																			:user_id => current_user.id)

		@story_all = false

		if @story_notifications.present? && @story_notifications.length == 1 && @story_notifications.first.identifier.nil?
			@story_all = true
		end

		# get story comments
		@story_comment = Notification.where(:notification_type => Notification::TYPES[:story_comment], :user_id => current_user.id).present?

		# get news
		@news = Notification.where(:notification_type => Notification::TYPES[:published_news],:user_id => current_user.id).present?

    # users following
    @following_users = current_user.following_users

		flash[:notice] = msg.join("<br />").html_safe if !msg.empty?
	end

protected

  def asset_filter
    @css.push("navbar.css", "settings.css", "tipsy.css")   
    @js.push("settings.js", "jquery.tipsy.js")   
  end

end



