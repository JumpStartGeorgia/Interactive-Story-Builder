class RemoveDupTranslationRecords < ActiveRecord::Migration
  def up
    Story.transaction do 

      # only keep the translation record with the smaller id for that is the one that would be used by the app

      # story
      puts "STORY"
      sql = 'select story_id, locale, count(*) as c from story_translations group by story_id, locale having c > 1'
      records = StoryTranslation.find_by_sql(sql)
      if records.present?
        records.each do |record|
          puts "- deleting story translation with story id #{record.story_id} and locale #{record.locale}"
          StoryTranslation.where(story_id: record.story_id, locale: record.locale).order('id desc').first.destroy
          # find the progress record and subtract one
          progress = StoryTranslationProgress.where(story_id: record.story_id, locale: record.locale).first
          main_progress = StoryTranslationProgress.where(story_id: record.story_id, is_story_locale: true).first
          if progress.present? && main_progress.present? && progress.items_completed > main_progress.items_completed
            puts "-> reducing progress count"
            progress.items_completed -= 1
            progress.save
          end
        end
      end

      # section
      puts "SECTION"
      sql = 'select section_id, locale, count(*) as c from section_translations group by section_id, locale having c > 1'
      records = SectionTranslation.find_by_sql(sql)
      if records.present?
        records.each do |record|
          puts "- deleting section translation with section id #{record.section_id} and locale #{record.locale}"
          SectionTranslation.where(section_id: record.section_id, locale: record.locale).order('id desc').first.destroy
          # find the progress record and subtract one
          progress = StoryTranslationProgress.where(story_id: record.story_id, locale: record.locale).first
          main_progress = StoryTranslationProgress.where(story_id: record.story_id, is_story_locale: true).first
          if progress.present? && main_progress.present? && progress.items_completed > main_progress.items_completed
            puts "-> reducing progress count"
            progress.items_completed -= 1
            progress.save
          end
        end
      end

      # content
      puts "CONTENT"
      sql = 'select content_id, locale, count(*) as c from content_translations group by content_id, locale having c > 1'
      records = ContentTranslation.find_by_sql(sql)
      if records.present?
        records.each do |record|
          puts "- deleting content translation with content id #{record.content_id} and locale #{record.locale}"
          ContentTranslation.where(content_id: record.content_id, locale: record.locale).order('id desc').first.destroy
          # find the progress record and subtract one
          progress = StoryTranslationProgress.where(story_id: record.content.section.story_id, locale: record.locale).first
          main_progress = StoryTranslationProgress.where(story_id: record.content.section.story_id, is_story_locale: true).first
          if progress.present? && main_progress.present? && progress.items_completed > main_progress.items_completed
            puts "-> reducing progress count"
            progress.items_completed -= 1
            progress.save
          end
        end
      end

      # embed
      puts "EMBED"
      sql = 'select embed_medium_id, locale, count(*) as c from embed_medium_translations group by embed_medium_id, locale having c > 1'
      records = EmbedMediumTranslation.find_by_sql(sql)
      if records.present?
        records.each do |record|
          puts "- deleting embed_medium translation with embed_medium id #{record.embed_medium_id} and locale #{record.locale}"
          EmbedMediumTranslation.where(embed_medium_id: record.embed_medium_id, locale: record.locale).order('id desc').first.destroy
          # find the progress record and subtract one
          progress = StoryTranslationProgress.where(story_id: record.embed_medium.section.story_id, locale: record.locale).first
          main_progress = StoryTranslationProgress.where(story_id: record.embed_medium.section.story_id, is_story_locale: true).first
          if progress.present? && main_progress.present? && progress.items_completed > main_progress.items_completed
            puts "-> reducing progress count"
            progress.items_completed -= 1
            progress.save
          end
        end
      end

      # infographic
      puts "INFOGRAPHIC"
      sql = 'select infographic_id, locale, count(*) as c from infographic_translations group by infographic_id, locale having c > 1'
      records = InfographicTranslation.find_by_sql(sql)
      if records.present?
        records.each do |record|
          puts "- deleting infographic translation with infographic id #{record.infographic_id} and locale #{record.locale}"
          InfographicTranslation.where(infographic_id: record.infographic_id, locale: record.locale).order('id desc').first.destroy
          # find the progress record and subtract one
          progress = StoryTranslationProgress.where(story_id: record.infographic.section.story_id, locale: record.locale).first
          main_progress = StoryTranslationProgress.where(story_id: record.infographic.section.story_id, is_story_locale: true).first
          if progress.present? && main_progress.present? && progress.items_completed > main_progress.items_completed
            puts "-> reducing progress count"
            progress.items_completed -= 1
            progress.save
          end
        end
      end

      # medium
      puts "MEDIUM"
      sql = 'select medium_id, locale, count(*) as c from medium_translations group by medium_id, locale having c > 1'
      records = MediumTranslation.find_by_sql(sql)
      if records.present?
        records.each do |record|
          puts "- deleting medium translation with medium id #{record.medium_id} and locale #{record.locale}"
          MediumTranslation.where(medium_id: record.medium_id, locale: record.locale).order('id desc').first.destroy
          # find the progress record and subtract one
          progress = StoryTranslationProgress.where(story_id: record.medium.section.story_id, locale: record.locale).first
          main_progress = StoryTranslationProgress.where(story_id: record.medium.section.story_id, is_story_locale: true).first
          if progress.present? && main_progress.present? && progress.items_completed > main_progress.items_completed
            puts "-> reducing progress count"
            progress.items_completed -= 1
            progress.save
          end
        end
      end

      # slideshow
      puts "SLIDESHOW"
      sql = 'select slideshow_id, locale, count(*) as c from slideshow_translations group by slideshow_id, locale having c > 1'
      records = SlideshowTranslation.find_by_sql(sql)
      if records.present?
        records.each do |record|
          puts "- deleting slideshow translation with slideshow id #{record.slideshow_id} and locale #{record.locale}"
          SlideshowTranslation.where(slideshow_id: record.slideshow_id, locale: record.locale).order('id desc').first.destroy
          # find the progress record and subtract one
          progress = StoryTranslationProgress.where(story_id: record.slideshow.section.story_id, locale: record.locale).first
          main_progress = StoryTranslationProgress.where(story_id: record.slideshow.section.story_id, is_story_locale: true).first
          if progress.present? && main_progress.present? && progress.items_completed > main_progress.items_completed
            puts "-> reducing progress count"
            progress.items_completed -= 1
            progress.save
          end
        end
      end

      # youtube
      puts "YOUTUBE"
      sql = 'select youtube_id, locale, count(*) as c from youtube_translations group by youtube_id, locale having c > 1'
      records = YoutubeTranslation.find_by_sql(sql)
      if records.present?
        records.each do |record|
          puts "- deleting youtube translation with youtube id #{record.youtube_id} and locale #{record.locale}"
          YoutubeTranslation.where(youtube_id: record.youtube_id, locale: record.locale).order('id desc').first.destroy
          # find the progress record and subtract one
          progress = StoryTranslationProgress.where(story_id: record.youtube.section.story_id, locale: record.locale).first
          main_progress = StoryTranslationProgress.where(story_id: record.youtube.section.story_id, is_story_locale: true).first
          if progress.present? && main_progress.present? && progress.items_completed > main_progress.items_completed
            puts "-> reducing progress count"
            progress.items_completed -= 1
            progress.save
          end
        end
      end

    end
  end

  def down
    # do nothing
  end
end
