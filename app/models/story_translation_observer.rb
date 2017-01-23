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


    def after_save(record)
      # code to calculate theme stories count
      # on create or update published field prepare to recalculate only specific locale
        if record.published_changed?
          @changes = [record.story.theme_ids, [record.locale], record.published ? 1 : -1]
        end
    end

    def after_destroy(record)
      # code to calculate theme stories count
      # when old is removed prepare to recalculate only specific locale and only if was published
        @changes = [record.story.theme_ids, [record.locale], -1] if record.published
    end


    # record the progress
    def after_commit(record)
      # code to calculate theme stories count
      # only recalculate if commit is called and changes.present?
        Theme.stories_count_recalculate(@changes) if @changes.present?

      if record.progress_story_id.present?
        options = {}
        options[:is_story_locale] = true if record.is_progress_increment && record.story.story_locale == record.locale
        options[:is_progress_increment] = record.is_progress_increment
        StoryTranslationProgress.update_progress(record.progress_story_id, record.locale, options)
      end

      return true
    end


end
