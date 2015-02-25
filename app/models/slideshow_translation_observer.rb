class SlideshowTranslationObserver < ActiveRecord::Observer
  
  def after_create(record)
    record.is_progress_increment = true
    record.progress_story_id = record.slideshow.section.story_id

    return true
  end

  def after_destroy(record)
    record.is_progress_increment = false
    record.progress_story_id = record.slideshow.section.story_id

    return true
  end


  # record the progress
  def after_commit(record)
    if record.progress_story_id.present?    
      options = {}
      options[:is_progress_increment] = record.is_progress_increment
      StoryTranslationProgress.update_progress(record.progress_story_id, record.locale, options)      
    end
    
    return true
  end

end
