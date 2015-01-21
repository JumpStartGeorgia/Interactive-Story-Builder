class TranslateEmbed < ActiveRecord::Migration
  def up
    # rename the existing columns
    rename_column :embed_media, :title, :old_title
    rename_column :embed_media, :url, :old_url
    rename_column :embed_media, :code, :old_code

    # create translation table
    EmbedMedium.create_translation_table! :title => :string, :url => :string, :code => :text

    # move the data using the story_locale as the translation locale
    Story.transaction do
      Story.all.each do |story|
        puts "- id =#{story.id}; locale = #{story.story_locale}"
        story.sections.each do |section|
          if section.embed_media? && section.embed_medium.present?
            puts "-- section id #{section.id}, embed_medium id = #{section.embed_medium.id}"
            trans = section.embed_medium.embed_medium_translations.build(:locale => story.story_locale)
            trans.title = section.embed_medium.old_title
            trans.url = section.embed_medium.old_url
            trans.code = section.embed_medium.old_code
            trans.save
          end
        end        
      end
    end

  end

  def down
    # drop translation table
    EmbedMedium.drop_translation_table!

    # rename exisitng columns
    rename_column :embed_media, :old_title, :title
    rename_column :embed_media, :old_url, :url
    rename_column :embed_media, :old_code, :code

  end
end
