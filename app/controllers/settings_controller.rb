class SettingsController < ApplicationController
  before_filter :authenticate_user!, :except => [:check_nickname]


  def index
    @css.push("settings.css", "devise.css", "bootstrap-select.min.css","navbar.css")
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
      if user_signed_in? && current_user.nickname == params[:nickname].strip.downcase
        output[:permalink] = current_user.permalink
      else
        u = User.new(:nickname => params[:nickname])
        u.generate_permalink
        output = {:permalink => u.permalink, :is_duplicate => u.is_duplicate_permalink?}
      end
    end
          
    respond_to do |format|     
      format.json { render json: output } 
    end
  end 
  
  
  # view invitations that are currently on record for this user
  def invitations
    @invitations = Invitation.where(['to_user_id = ? and accepted_at is null', current_user.id] )
    
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
          redirect_to stories_path, :notice => t('app.msgs.invitation_accepted', :title => s.title)
          accepted = true
        end
      else
        redirect_to stories_path, :notice => t('app.msgs.invitation_accepted_already', :title => s.title)
        accepted = true
      end
    end

    if !accepted
      redirect_to invitations_path, :notice => t('app.msgs.bad_invitation')  
    end
  end  

end
