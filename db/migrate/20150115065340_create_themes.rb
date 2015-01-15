class CreateThemes < ActiveRecord::Migration
  def up
    create_table :themes do |t|
      t.boolean :is_published, :default => false
      t.date :published_at
      t.boolean :show_home_page, :default => false

      t.timestamps
    end

    add_index :themes, [:is_published, :published_at]
    add_index :themes, :show_home_page

    Theme.create_translation_table! :name => :string, :edition => :string, :description => :text, :permalink => :string
    add_index :theme_translations, :name
    add_index :theme_translations, :permalink
  end

  def down
    drop_table :themes
    Theme.drop_translation_table!
  end

end
