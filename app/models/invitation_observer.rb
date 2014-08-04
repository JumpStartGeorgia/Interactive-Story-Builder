class InvitationObserver < ActiveRecord::Observer
  
  def after_create(invitation)
    invitation.send_notification = true  
    return true
  end

  # send notification
  def after_commit(invitation)
    if invitation.send_notification
      NotificationTrigger.add_story_collaboration(invitation.id)
    end
    return true
  end
end
