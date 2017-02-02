class CreateHighlights < ActiveRecord::Migration
  def up
    create_table :highlights do |t|
      t.boolean :picked, :default => false
      t.timestamps
    end
    add_index :highlights, :picked
    Highlight.create_translation_table! :caption => :string, :url => :string
  end

  def down
    drop_table :highlights
    Highlight.drop_translation_table!
  end
end
