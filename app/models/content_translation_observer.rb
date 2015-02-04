class ContentTranslationObserver < ActiveRecord::Observer
  
  def after_create(record)
    Rails.logger.debug "@@@@@@@@@@ content trans after create"
    record.progress_action = 'inc'

    return true
  end

  def before_destroy(record)
    Rails.logger.debug "@@@@@@@@@@ content trans before destroy"
    record.progress_action = 'dec'

    return true
  end


  # record the progress
  def after_commit(record)
    Rails.logger.debug "@@@@@@@@@@ content trans after commit"

    options = {}
    options[:action] = record.progress_action
    story_id = record.content.section.story_id
    StoryTranslationProgress.update_progress(story_id, record.locale, options)      

    return true
  end
end
