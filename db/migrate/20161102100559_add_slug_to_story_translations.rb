class AddSlugToStoryTranslations < ActiveRecord::Migration
  def change
      add_column :story_translations, :slug, :string
      add_index :story_translations, :slug, unique: true
  end
end
