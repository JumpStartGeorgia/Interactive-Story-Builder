class RemoveAuthorFromStoryTranslation < ActiveRecord::Migration
  def up
    remove_column :story_translations, :author
  end

  def down
    Story.add_translation_fields! author: :string
  end
end
