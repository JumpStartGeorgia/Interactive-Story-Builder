class CreateAuthors < ActiveRecord::Migration
  def up
    create_table :authors do |t|

      t.timestamps
    end

    Author.create_translation_table! :name => :string, :about => :text, :permalink => :string
    add_index :author_translations, :name
    add_index :author_translations, :permalink
  end

  def down
    drop_table :authors
    Author.drop_translation_table!
  end
end
