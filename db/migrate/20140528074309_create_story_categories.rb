class CreateStoryCategories < ActiveRecord::Migration
  def change
    create_table :story_categories do |t|
      t.integer :story_id
      t.integer :category_id

      t.timestamps
    end
    
    add_index :story_categories, :story_id
    add_index :story_categories, :category_id
  end
end
