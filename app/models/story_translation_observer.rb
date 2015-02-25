class StoryTranslationObserver < ActiveRecord::Observer
  
  def after_create(record)
    record.is_progress_increment = true
    record.progress_story_id = record.story.id

    return true
  end

  # don't need this since the record will automatically be delete due to
  # has_many :story_translation_progresses, :dependent => :destroy
  # def after_destroy(record)
  #   Rails.logger.debug "@@@@@@@@@@ story trans after destroy"
  #   record.is_progress_increment = false
  #   record.progress_story_id = record.story.id

  #   return true
  # end


  # record the progress
  def after_commit(record)
    if record.progress_story_id.present?    
      options = {}
      options[:is_story_locale] = true if record.is_progress_increment && record.story.story_locale == record.locale
      options[:is_progress_increment] = record.is_progress_increment
      StoryTranslationProgress.update_progress(record.progress_story_id, record.locale, options)      
    end

    return true
  end

end
