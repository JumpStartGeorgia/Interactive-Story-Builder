module FixStoryLocales

  TEMP_LOCALE = 'zz'

  # for all translation records in a story, switch the provided locales
  def self.swap(story_id, locale1, locale2)
    Story.transaction do
      if !story_id.present? || !locale1.present? || !locale2.present?
        puts "ERROR - Please provide all parameters: story_id, locale1 and locale2"
        return false
      end

      story = Story.find(story_id)

      if !story.present?
        puts "ERROR - Story with id '#{story_id}' could not be found"
        return false
      end

      # make sure locales are strings
      locale1 = locale1.to_s
      locale2 = locale2.to_s

      # see if story has these locales
      locales = story.story_locales
      if !locales.present? || !locales.include?(locale1) || !locales.include?(locale2)
        puts "ERROR - Story only has locales #{locales.join(', ')} and at least one of the provided locales (#{locale1}, #{locale2}) were not found"
        return false
      end

      # story translations
      puts "----------"
      puts "----------"
      puts "Story Translations"
      if !update_translation_records(story.story_translations, locale1, locale2)
        raise ActiveRecord::Rollback
        return false
      end
      if !update_translation_record(story.story_translations, locale1)
        raise ActiveRecord::Rollback
        return false
      end

      # section translations
      puts "----------"
      puts "----------"
      puts "* Section Translations"
      story.sections.each do |section|
        puts "----------"
        puts "----------"
        puts "----------"
        puts "** section #{section.id}"
        if !update_translation_records(section.section_translations, locale1, locale2)
          raise ActiveRecord::Rollback
          return false
        end
        if !update_translation_record(section.section_translations, locale1)
          raise ActiveRecord::Rollback
          return false
        end

        # content
        if section.content? && section.content.present?
          puts "----------"
          puts "*** content #{section.content.id}"
          if !update_translation_records(section.content.content_translations, locale1, locale2)
            raise ActiveRecord::Rollback
            return false
          end
          if !update_translation_record(section.content.content_translations, locale1)
            raise ActiveRecord::Rollback
            return false
          end
        end

        # embed
        if section.embed_media? && section.embed_medium.present?
          puts "----------"
          puts "*** embed #{section.embed_medium.id}"
          if !update_translation_records(section.embed_medium.embed_medium_translations, locale1, locale2)
            raise ActiveRecord::Rollback
            return false
          end
          if !update_translation_record(section.embed_medium.embed_medium_translations, locale1)
            raise ActiveRecord::Rollback
            return false
          end
        end

        # youtube embed
        if section.youtube? && section.youtube.present?
          puts "----------"
          puts "*** youtube #{section.youtube.id}"
          if !update_translation_records(section.youtube.youtube_translations, locale1, locale2)
            raise ActiveRecord::Rollback
            return false
          end
          if !update_translation_record(section.youtube.youtube_translations, locale1)
            raise ActiveRecord::Rollback
            return false
          end
        end

        # media
        if section.media? && section.media.present?
          section.media.each do |medium|
            puts "----------"
            puts "*** media #{medium.id}"
            if !update_translation_records(medium.medium_translations, locale1, locale2)
              raise ActiveRecord::Rollback
              return false
            end
            if !update_translation_record(medium.medium_translations, locale1)
              raise ActiveRecord::Rollback
              return false
            end
          end
        end

        # slideshow
        if section.slideshow? && section.slideshow.present?
          puts "----------"
          puts "*** slideshow #{section.slideshow.id}"
          if !update_translation_records(section.slideshow.slideshow_translations, locale1, locale2)
            raise ActiveRecord::Rollback
            return false
          end
          if !update_translation_record(section.slideshow.slideshow_translations, locale1)
            raise ActiveRecord::Rollback
            return false
          end
        end
      end

    end
    return nil
  end

private

  # for the provided list of transaction records, find locale1 and locale2 and then swap them
  # - locale1 will be set to 'zz' (temp locale) so records can be saved 
  #   for setting 1 to 2 and 2 to 1 will cause duplicate validation error
  def self.update_translation_records(translation_array, locale1, locale2)
    if translation_array.present?
      l1 = translation_array.select{|x| x.locale == locale1}.first
      l2 = translation_array.select{|x| x.locale == locale2}.first

      if !l1.present?
        puts "!!!! ERROR - could not find locale1 #{locale1}"
        return false
      elsif !l2.present?
        puts "!!!! ERROR - could not find locale2 #{locale2}"
        return false
      end

      l2.locale = TEMP_LOCALE
      l1.locale = locale2
      if !l2.save
        puts "!!!! SAVE ERROR FOR LOCALE2- #{l2.errors.full_messages}"
      elsif !l1.save
        puts "!!!! SAVE ERROR FOR LOCALE1- #{l1.errors.full_messages}"
      else
        return true
      end
    end
    return false
  end

  # for the provided list of transaction records, find TEMP_LOCALE and set to to_locale
  def self.update_translation_record(translation_array, to_locale)
    if translation_array.present?
      temp = translation_array.select{|x| x.locale == TEMP_LOCALE}.first

      if !temp.present?
        puts "!!!! ERROR - could not find temp locale #{TEMP_LOCALE}"
        return false
      end

      temp.locale = to_locale
      return temp.save
    end
    return false
  end


end