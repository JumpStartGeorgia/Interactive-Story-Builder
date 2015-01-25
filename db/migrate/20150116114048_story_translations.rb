class StoryTranslations < ActiveRecord::Migration
  def up
    # rename the existing columns
    rename_column :stories, :title, :old_title
    rename_column :stories, :permalink, :old_permalink
    rename_column :stories, :permalink_staging, :old_permalink_staging
    rename_column :stories, :author, :old_author
    rename_column :stories, :media_author, :old_media_author
    rename_column :stories, :about, :old_about
#    rename_column :stories, :story_locale, :old_story_locale
    rename_column :stories, :published, :old_published
    rename_column :stories, :published_at, :old_published_at

    # create the new translations columns
    Story.add_translation_fields! title: :string
    Story.add_translation_fields! permalink: :string
    Story.add_translation_fields! permalink_staging: :string
    Story.add_translation_fields! author: :string
    Story.add_translation_fields! media_author: :string
    Story.add_translation_fields! about: :text
    Story.add_translation_fields! published: {type: :boolean, default: false}
    Story.add_translation_fields! published_at: :datetime
    Story.add_translation_fields! language_type: {type: :integer, limit: 1, default: 0}
    Story.add_translation_fields! translation_percent_complete: {type: :integer, limit: 1, default: 0}
    Story.add_translation_fields! translation_author: :string

    add_index :story_translations, :title
    add_index :story_translations, :permalink
    add_index :story_translations, :published
    add_index :story_translations, :published_at
    add_index :story_translations, :language_type

    # fix story_locale so it does not have default value
    change_column :stories, :story_locale, :string, :default => nil

    # move the data using the story_locale as the translation locale
    Story.transaction do
      Story.all.each do |story|
        puts "- id = #{story.id}; story locale = #{story.story_locale}; current_locale = #{story.current_locale}"
        
        trans = story.translation_for(story.current_locale)
        trans.title = story.old_title
        trans.permalink = story.old_permalink
        trans.permalink_staging = story.old_permalink_staging
        trans.author = story.old_author
        trans.media_author = story.old_media_author
        trans.about = story.old_about
        trans.published = story.old_published
        trans.published_at = story.old_published_at
        trans.save

        # if story translation for this locale already exists, use it, 
        # else create a new translation record
        # index = story.story_translations.index{|x| x.locale == story.story_locale}
        # if index.present?
        #   puts "-- updating"
        #   # update
        #   trans = story.story_translations[index]
        #   trans.title = story.old_title
        #   trans.permalink = story.old_permalink
        #   trans.permalink_staging = story.old_permalink_staging
        #   trans.author = story.old_author
        #   trans.media_author = story.old_media_author
        #   trans.about = story.old_about
        #   trans.published = story.old_published
        #   trans.published_at = story.old_published_at
        #   trans.save
        # else
        #   puts "-- adding"
        #   # add
        #   trans = story.story_translations.build(:locale => story.story_locale)
        #   trans.title = story.old_title
        #   trans.permalink = story.old_permalink
        #   trans.permalink_staging = story.old_permalink_staging
        #   trans.author = story.old_author
        #   trans.media_author = story.old_media_author
        #   trans.about = story.old_about
        #   trans.published = story.old_published
        #   trans.published_at = story.old_published_at
        #   trans.save
        # end
      end
    end
  end

  def down
    # drop translation columns
    remove_index :story_translations, :title
    remove_index :story_translations, :permalink
    remove_index :story_translations, :published
    remove_index :story_translations, :published_at
    remove_index :story_translations, :language_type

    remove_column :story_translations, :title
    remove_column :story_translations, :permalink
    remove_column :story_translations, :permalink_staging
    remove_column :story_translations, :author
    remove_column :story_translations, :media_author
    remove_column :story_translations, :about
    remove_column :story_translations, :published
    remove_column :story_translations, :published_at
    remove_column :story_translations, :language_type
    remove_column :story_translations, :translation_percent_complete
    remove_column :story_translations, :translation_author

    # rename exisitng columns
    rename_column :stories, :old_title, :title
    rename_column :stories, :old_permalink, :permalink
    rename_column :stories, :old_permalink_staging, :permalink_staging
    rename_column :stories, :old_author, :author
    rename_column :stories, :old_media_author, :media_author
    rename_column :stories, :old_about, :about
#    rename_column :stories, :old_story_locale, :story_locale
    rename_column :stories, :old_published, :published
    rename_column :stories, :old_published_at, :published_at
  end
end
