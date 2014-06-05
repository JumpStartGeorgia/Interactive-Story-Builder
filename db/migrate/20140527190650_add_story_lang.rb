class AddStoryLang < ActiveRecord::Migration
  def up
    add_column :stories, :locale, :string, :default => 'en'
    add_index :stories, :locale
    
    Story.update_all(:locale => 'en')
  end

  def down
    remove_index :stories, :locale
    remove_column :stories, :locale
  end
end
