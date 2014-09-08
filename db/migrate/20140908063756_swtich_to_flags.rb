class SwtichToFlags < ActiveRecord::Migration
  def up
    remove_index :languages, :published_story_count
    remove_column :languages, :published_story_count
    remove_index :categories, :published_story_count
    remove_column :categories, :published_story_count

    add_column :languages, :has_published_stories, :boolean, :default => false
    add_index :languages, :has_published_stories
    add_column :categories, :has_published_stories, :boolean, :default => false
    add_index :categories, :has_published_stories

    Language.update_published_stories_flags
    Category.update_published_stories_flags
  end

  def down
    remove_index :languages, :has_published_stories
    remove_column :languages, :has_published_stories
    remove_index :categories, :has_published_stories
    remove_column :categories, :has_published_stories

    add_column :languages, :published_story_count, :integer, :default => 0
    add_index :languages, :published_story_count
    add_column :categories, :published_story_count, :integer, :default => 0
    add_index :categories, :published_story_count
  end
end
