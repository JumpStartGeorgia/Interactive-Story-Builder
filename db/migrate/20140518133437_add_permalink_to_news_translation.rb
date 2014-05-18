class AddPermalinkToNewsTranslation < ActiveRecord::Migration
  def self.up
    add_column :news_translations, :permalink, :string
    add_index :news_translations, :permalink
  end
  def self.down
    remove_column :news_translations, :permalink
  end
end