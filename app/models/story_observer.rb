class StoryObserver < ActiveRecord::Observer
  
  def after_save(story)
    story.send_notification = story.published_changed? && story.published == true  
  end

  # send notification
  def after_commit(story)
    if story.send_notification
      NotificationTrigger.add_published_story(story.id)
    end
  end
end
