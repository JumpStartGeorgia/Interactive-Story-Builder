class StoryObserver < ActiveRecord::Observer
  
  def after_save(story)
    story.send_notification = true if story.published_changed?    
  end

  # send notification
  def after_commit(story)
    if story.send_notification
      NotificationTrigger.add_story_published(story.id)
    end
  end
end
