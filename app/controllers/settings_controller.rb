class SettingsController < ApplicationController
  before_filter :authenticate_user!, :except => [:check_nickname]


  def index
    @load_bootstrap_select = true

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
    @load_bootstrap_select = true

    if current_user.has_provider_avatar? && current_user.local_avatar_exists?
      current_user.local_avatar = nil
      current_user.save
    end

    flash[:notice] = I18n.t('app.msgs.success_remove_avatar')

    redirect_to settings_path  
  end   
  
  def check_nickname
    output = {:permalink => nil, :is_duplicate => false}
    if user_signed_in? && current_user.nickname == params[:nickname].strip.downcase
      output[:permalink] = current_user.permalink
    else
      u = User.new(:nickname => params[:nickname])
      u.generate_permalink
      output = {:permalink => u.permalink, :is_duplicate => u.is_duplicate_permalink?}
    end
      
    respond_to do |format|     
      format.json { render json: output } 
    end
  end 
end
