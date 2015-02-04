class CreateStoryTranslationProgresses < ActiveRecord::Migration
  def up
    # create_table :story_translation_progresses do |t|
    #   t.integer :story_id
    #   t.string :locale
    #   t.integer :items_completed, :default => 0
    #   t.boolean :is_story_locale, :default => false
    #   t.boolean :can_publish, :default => false

    #   t.timestamps
    # end

    # add_index :story_translation_progresses, [:story_id, :locale]
    # add_index :story_translation_progresses, [:story_id, :can_publish]


    start = Time.now

    # add counts for each story
    StoryTranslationProgress.transaction do
      # save all counts to has firts
      s = Story.all.each do |s|
        puts "========="
        puts "========="
        puts "story #{s.id}"
        counts = Hash.new(0)
        # story
        s.story_translations.each do |trans|
          counts[trans.locale] += 1 
        end

        # section
        s.sections.each do |section|
          puts " - section #{section.id}"
          section.section_translations.each do |trans|
            counts[trans.locale] += 1 
          end

          # content
          if section.content? && section.content.present?
            section.content.content_translations.each do |trans|
              puts "   - content #{trans.content_id}"
              counts[trans.locale] += 1 
            end
          end

          # embed
          if section.embed_media? && section.embed_medium.present?
            section.embed_medium.embed_medium_translations.each do |trans|
              puts "   - embed #{trans.embed_medium_id}"
              counts[trans.locale] += 1 
            end
          end

          # youtube embed
          if section.youtube? && section.youtube.present?
            section.youtube.youtube_translations.each do |trans|
              puts "   - youtube #{trans.youtube_id}"
              counts[trans.locale] += 1 
            end
          end

          # media
          if section.media? && section.media.present?
            section.media.each do |medium|
              puts "   - media #{medium.id}"
              medium.medium_translations.each do |trans|
                counts[trans.locale] += 1 
              end
            end
          end

          # slideshow
          if section.slideshow? && section.slideshow.present?
            section.slideshow.slideshow_translations.each do |trans|
              puts "   - slideshow #{trans.slideshow_id}"
              counts[trans.locale] += 1 

              # asset image - increase by number of images
              counts[trans.locale] += trans.assets.length
            end
          end
        end

        # if counts has keys, add them to the table
        if counts.keys.length > 0
          # first process the story_locale count
          count_index = counts.keys.index{|x| s.story_locale == x}
          story_progress = nil
          story_locale = nil
          if count_index.present?
            story_locale = counts.keys[count_index]
            story_progress = StoryTranslationProgress.create(story_id: s.id, locale: story_locale, items_completed: counts[story_locale], 
                    is_story_locale: true, can_publish: true)
          end

          counts.keys.each do |locale|
            if locale != story_locale
              progress = StoryTranslationProgress.new(story_id: s.id, locale: locale, items_completed: counts[locale])
              # indicate whether or not the translation can be published
              if story_progress.present?
                progress.can_publish = story_progress.items_completed == progress.items_completed
              end 
              progress.save
            end
          end
        end
      end
    end

    puts "========="
    puts "========="
    puts "========="
    puts "took #{Time.now-start} seconds for #{Story.count} stories"
    puts "========="
  end

  def down
    drop_table :story_translation_progresses
  end
end
