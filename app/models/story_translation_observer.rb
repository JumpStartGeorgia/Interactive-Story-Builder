class StoryTranslationObserver < ActiveRecord::Observer
  
  def after_create(record)
    Rails.logger.debug "@@@@@@@@@@ story trans after create"
    record.progress_action = 'inc'

    return true
  end

  # don't have to do this since story takes care of this through has_many :story_translation_progresses, :dependent => :destroy
  # def after_destroy(record)
  #   Rails.logger.debug "@@@@@@@@@@ story trans after destroy"
  #   record.progress_action = 'dec'

  #   return true
  # end


  # record the progress
  def after_commit(record)
    Rails.logger.debug "@@@@@@@@@@ story trans after commit"

    options = {}
    options[:is_story_locale] = true if record.story.story_locale == record.locale
    options[:action] = record.progress_action
    story_id = record.story_id
    StoryTranslationProgress.update_progress(story_id, record.locale, options)      

    return true
  end
end
