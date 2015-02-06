class ThemeObserver < ActiveRecord::Observer
  
  def after_save(theme)
    theme.send_notification = theme.is_published_changed? && theme.is_published == true  

  end

  # send notification
  def after_commit(theme)
    if theme.send_notification
      NotificationTrigger.add_published_theme(theme.id)
    end

    return true
  end
end
