class AddCategoryCount < ActiveRecord::Migration
  def up
    add_column :categories, :published_story_count, :integer, :default => 0
    add_index :categories, :published_story_count
    
    # create counts for categories that are published
    Category.update_counts
  end

  def down
    remove_index :categories, :published_story_count
    remove_column :categories, :published_story_count
  end
end
