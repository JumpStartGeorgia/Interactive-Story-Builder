class TieStoryToTheme < ActiveRecord::Migration
  def up
    add_column :stories, :story_type_id, :integer
    add_index :stories, :story_type_id


    create_table :story_themes do |t|
      t.integer :story_id
      t.integer :theme_id
      t.timestamps
    end
    add_index :story_themes, :story_id
    add_index :story_themes, :theme_id

  end

  def down
    remove_index :stories, :story_type_id
    remove_column :stories, :story_type_id

    drop_table :story_themes

  end
end
