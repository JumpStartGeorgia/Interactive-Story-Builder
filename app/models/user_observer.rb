class UserObserver < ActiveRecord::Observer

  # send notification if the agenda/law is now public
  def after_create(user)
    user.send_notification = true    
  end

  # send notification
  def after_commit(user)
    if user.send_notification
      NotificationTrigger.add_account_created(user.id)
    end
  end
end
