class CreateStoryAuthors < ActiveRecord::Migration
  def change
    create_table :story_authors do |t|
      t.integer :story_id
      t.integer :author_id

      t.timestamps
    end
    add_index :story_authors, :story_id
    add_index :story_authors, :author_id
  end
end
