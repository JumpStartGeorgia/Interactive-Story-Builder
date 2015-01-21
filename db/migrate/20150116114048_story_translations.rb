class StoryTranslations < ActiveRecord::Migration
  def up
    # rename the existing columns
    rename_column :stories, :title, :old_title
    rename_column :stories, :permalink, :old_permalink
    rename_column :stories, :permalink_staging, :old_permalink_staging
    rename_column :stories, :author, :old_author
    rename_column :stories, :media_author, :old_media_author
    rename_column :stories, :about, :old_about

    # create the new translations columns
    Story.add_translation_fields! title: :string
    Story.add_translation_fields! permalink: :string
    Story.add_translation_fields! permalink_staging: :string
    Story.add_translation_fields! author: :string
    Story.add_translation_fields! media_author: :string
    Story.add_translation_fields! about: :text

    add_index :story_translations, :title
    add_index :story_translations, :permalink

    # move the data using the story_locale as the translation locale
    Story.transaction do
      Story.all.each do |story|
        puts "- id =#{story.id}; locale = #{story.story_locale}"
        # if story translation for this locale already exists, use it, 
        # else create a new translation record
        index = story.story_translations.index{|x| x.locale == story.story_locale}
        if index.present?
          puts "-- updating"
          # update
          trans = story.story_translations[index]
          trans.title = story.old_title
          trans.permalink = story.old_permalink
          trans.permalink_staging = story.old_permalink_staging
          trans.author = story.old_author
          trans.media_author = story.old_media_author
          trans.about = story.old_about
          trans.save
        else
          puts "-- adding"
          # add
          trans = story.story_translations.build(:locale => story.story_locale)
          trans.title = story.old_title
          trans.permalink = story.old_permalink
          trans.permalink_staging = story.old_permalink_staging
          trans.author = story.old_author
          trans.media_author = story.old_media_author
          trans.about = story.old_about
          trans.save
        end
      end
    end
  end

  def down
    # drop translation columns
    remove_index :story_translations, :title
    remove_index :story_translations, :permalink

    remove_column :story_translations, :title
    remove_column :story_translations, :permalink
    remove_column :story_translations, :author
    remove_column :story_translations, :media_author
    remove_column :story_translations, :about

    # rename exisitng columns
    rename_column :stories, :old_title, :title
    rename_column :stories, :old_permalink, :permalink
    rename_column :stories, :old_permalink_staging, :permalink_staging
    rename_column :stories, :old_author, :author
    rename_column :stories, :old_media_author, :media_author
    rename_column :stories, :old_about, :about
  end
end
