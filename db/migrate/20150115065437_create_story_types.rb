class CreateStoryTypes < ActiveRecord::Migration
  def up
    create_table :story_types do |t|
      t.integer :sort_order, :limit => 1, :default => 0
      t.timestamps
    end

    StoryType.create_translation_table! :name => :string, :permalink => :string
    add_index :story_type_translations, :name
    add_index :story_type_translations, :permalink
  end

  def down
    drop_table :story_types
    StoryType.drop_translation_table!
  end

end
