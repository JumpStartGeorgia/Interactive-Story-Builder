class StoryTranslationProgress < ActiveRecord::Base
  belongs_to :story

  attr_accessible :story_id, :locale, :items_completed, :can_publish, :is_story_locale

  validates :story_id, :locale, :presence => true

  # get all of the progress records for a story
  def self.get_progress(story_id)
    where(:story_id => story_id)
  end


  # update the story translation progress
  # options: 
  # - story locale - set to true if this locale is the story locale; default = false
  # - is_progress_increment - true to increase; false to decrease; default = true
  def self.update_progress(story_id, locale, options={})
    is_story_locale = options[:is_story_locale]
    is_progress_increment = options[:is_progress_increment].nil? ? true : options[:is_progress_increment]
    reset_story_locale = false

    #Rails.logger.debug "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
    #Rails.logger.debug "&&&&&&&&&&&&&& translation progress update; story #{story_id}, locale #{locale}, is_story_locale #{is_story_locale}, is_progress_increment #{is_progress_increment}"
    #Rails.logger.debug "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"

    # see if record already exists    
    record = where(story_id: story_id, locale: locale).first
    
    # if the record was not found and this is a decrease, do nothing
    if !(record.blank? && !is_progress_increment)
      if record.blank?
        # this is the first update, so create the record
        record = StoryTranslationProgress.new(story_id: story_id, locale: locale)
      end

      # if is_story_locale is provided, set it to true
      if is_story_locale.present?
        record.is_story_locale = true 
        reset_story_locale = true
      end

      # change the count
      if is_progress_increment
        record.items_completed += 1
      else
        record.items_completed -= 1
      end

      record.save

      # if the story locale was set, make sure no other locales in this story have this flag set
      where(['story_id = ? and id != ?', story_id, record.id]).update_all(is_story_locale: false) if reset_story_locale

    end
  end

  # story was deleted so delete all progress for the story
  def self.delete_progress(story_id)
    #Rails.logger.debug "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
    #Rails.logger.debug "&&&&&&&&&&&&&& translation progress deletion; story #{story_id}"
    #Rails.logger.debug "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
    where(story_id: story_id).delete_all
  end


  # determine whether all of the records that need to be translated are translated before published
  # - if locale is the story_locale, then the return value will always be true
  def self.can_publish?(story_id, locale)
    can_publish = false

    records = where(story_id: story_id)
    primary = records.select{|x| x.is_story_locale?}.first

    if primary.present?
      if primary.locale == locale.to_s
        can_publish = true
      else
        record = records.select{|x| x.locale == locale.to_s}.first
        can_publish = record.present? && record.items_completed == primary.items_completed
      end
    end

    return can_publish
  end
end
