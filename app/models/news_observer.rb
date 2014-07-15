class NewsObserver < ActiveRecord::Observer
  
  def after_save(news)
    news.send_notification = news.is_published_changed? && news.is_published == true  
  end

  # send notification
  def after_commit(news)
    if news.send_notification
      NotificationTrigger.add_published_news(news.id)
    end
  end
end
