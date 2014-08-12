class UserObserver < ActiveRecord::Observer

  # send notification if the agenda/law is now public
  def after_create(user)
    user.send_notification = true    
    return true
  end

  # send notification
  def after_commit(user)
    if user.send_notification
      NotificationTrigger.add_new_user(user.id)
    end
    return true
  end
end
