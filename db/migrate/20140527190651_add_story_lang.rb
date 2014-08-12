class AddStoryLang < ActiveRecord::Migration
  def up
    s = Story.first
  
    if s.has_attribute?(:locale)
      rename_column :stories, :locale, :story_locale
    else
      add_column :stories, :story_locale, :string, :default => 'en'
      add_index :stories, :story_locale
    end
    
    Story.update_all(:story_locale => 'en')
  end

  def down
    remove_index :stories, :story_locale
    remove_column :stories, :story_locale
  end
end
