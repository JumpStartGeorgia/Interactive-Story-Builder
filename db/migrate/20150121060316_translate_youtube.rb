class TranslateYoutube < ActiveRecord::Migration
  def up
    # rename the existing columns
    rename_column :youtubes, :title, :old_title
    rename_column :youtubes, :url, :old_url

    # create translation table
    Youtube.add_translation_fields! title: :string
    Youtube.add_translation_fields! url: :string

    # move the data using the story_locale as the translation locale
    Story.transaction do
      Story.all.each do |story|
        puts "- id =#{story.id}; locale = #{story.story_locale}"
        Globalize.story_locale = story.story_locale
        story.sections.each do |section|
          if section.youtube? && section.youtube.present?
            puts "-- section id #{section.id}, youtube id = #{section.youtube.id}; current_locale = #{section.current_locale}"

            trans = section.youtube.translation_for(story.story_locale)
            trans.title = section.youtube.old_title
            trans.url = section.youtube.old_url
            trans.save

            # if youtube translation for this locale already exists, use it, 
            # else create a new translation record
            # index = section.youtube.youtube_translations.index{|x| x.locale == story.story_locale}
            # if index.present?
            #   puts "-- updating"
            #   trans = section.youtube.youtube_translations[index]
            #   trans.title = section.youtube.old_title
            #   trans.url = section.youtube.old_url
            #   trans.save
            # else
            #   puts "-- adding"
            #   trans = section.youtube.youtube_translations.build(:locale => story.story_locale)
            #   trans.title = section.youtube.old_title
            #   trans.url = section.youtube.old_url
            #   trans.save
            # end              
          end
        end        
      end
    end

  end

  def down
    remove_column :youtube_translations, :title
    remove_column :youtube_translations, :url

    # rename exisitng columns
    rename_column :youtubes, :old_title, :title
    rename_column :youtubes, :old_url, :url

  end
end
