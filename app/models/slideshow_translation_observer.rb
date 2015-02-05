class SlideshowTranslationObserver < ActiveRecord::Observer
  
  def after_create(record)
    Rails.logger.debug "@@@@@@@@@@ slideshow trans after create"
    record.is_progress_increment = true
    record.progress_story_id = record.slideshow.section.story_id

    return true
  end

  def after_destroy(record)
    Rails.logger.debug "@@@@@@@@@@ slideshow trans after destroy"
    record.is_progress_increment = false
    record.progress_story_id = record.slideshow.section.story_id

    return true
  end


  # record the progress
  def after_commit(record)
    Rails.logger.debug "@@@@@@@@@@ slideshow trans after commit, story id #{record.progress_story_id; }; is_progress_increment = #{record.is_progress_increment}"

    options = {}
    options[:is_progress_increment] = record.is_progress_increment
    StoryTranslationProgress.update_progress(record.progress_story_id, record.locale, options)      

    return true
  end

end
