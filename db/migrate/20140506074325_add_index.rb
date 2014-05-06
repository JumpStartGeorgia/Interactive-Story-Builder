class AddIndex < ActiveRecord::Migration
  def change
    add_index :assets, [:item_id, :asset_type]
    add_index :assets, [:item_id, :position]
    add_index :sections, :position    
    add_index :contents, :section_id
    add_index :media, [:section_id, :position]
    add_index :stories, :published
    add_index :stories, :published_at
    add_index :stories_users, :story_id
    add_index :stories_users, :user_id
    add_index :templates, :title
  end
end
