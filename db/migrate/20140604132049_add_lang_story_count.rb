class AddLangStoryCount < ActiveRecord::Migration
  def up
    add_column :languages, :published_story_count, :integer, :default => 0
    add_index :languages, :published_story_count
    
    # create counts for stories that are published
    Story.transaction do 
      Story.is_published.each do |story|
        Language.increment_count(story.locale)
      end
    end
  end

  def down
    remove_index :languages, :published_story_count
    remove_column :languages, :published_story_count
  end
end
