class AddIndexForLinkFields < ActiveRecord::Migration
  def change
  	add_index :assets, :item_id
  	add_index :media, :section_id
  	add_index :sections, :story_id
  	add_index :stories, :user_id
  	add_index :stories, :template_id
  end
end
