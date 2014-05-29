class SettingsController < ApplicationController
  before_filter :authenticate_user!


  def index
    @load_bootstrap_select = true

    if request.put?
      if current_user.update_attributes(params[:user])
        flash[:notice] = I18n.t('app.msgs.success_settings')
      else
        flash[:error] = I18n.t('app.msgs.error_updated', obj:User.model_name.human, err:current_user.errors.full_messages.to_sentence)            
      end
    end
    
    respond_to do |format|     
      format.html 
    end
  end
    
end
