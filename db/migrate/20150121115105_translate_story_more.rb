class TranslateStoryMore < ActiveRecord::Migration
  def up
    # rename the existing columns
    rename_column :stories, :story_locale, :old_story_locale
    rename_column :stories, :published, :old_published
    rename_column :stories, :published_at, :old_published_at

    # create the new translations columns
    # story_locale in Story = locale in StoryTranslation
    Story.add_translation_fields! published: {type: :boolean, default: false}
    Story.add_translation_fields! published_at: :datetime
    Story.add_translation_fields! language_type: {type: :integer, limit: 1, default: 0}
    Story.add_translation_fields! translation_percent_complete: {type: :integer, limit: 1, default: 0}
    Story.add_translation_fields! translation_author: :string


    add_index :story_translations, :published
    add_index :story_translations, :published_at
    add_index :story_translations, :language_type

    # move the data using the story_locale as the translation locale
    Story.transaction do
      Story.all.each do |story|
        puts "- id =#{story.id}; locale = #{story.old_story_locale}"
        # if story translation for this locale already exists, use it, 
        # else create a new translation record
        index = story.story_translations.index{|x| x.locale == story.old_story_locale}
        if index.present?
          puts "-- updating"
          # update
          trans = story.story_translations[index]
          trans.published = story.old_published
          trans.published_at = story.old_published_at
          trans.save
        else
          puts "-- adding"
          # add
          trans = story.story_translations.build(:locale => story.old_story_locale)
          trans.published = story.old_published
          trans.published_at = story.old_published_at
          trans.save
        end
      end
    end
  end

  def down
    # drop translation columns
    remove_index :story_translations, :published
    remove_index :story_translations, :published_at
    remove_index :story_translations, :language_type

    remove_column :story_translations, :published
    remove_column :story_translations, :published_at
    remove_column :story_translations, :language_type
    remove_column :story_translations, :translation_percent_complete
    remove_column :story_translations, :translation_author

    # rename exisitng columns
    rename_column :stories, :old_story_locale, :story_locale
    rename_column :stories, :old_published, :published
    rename_column :stories, :old_published_at, :published_at
  end
end
