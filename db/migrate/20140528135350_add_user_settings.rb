class AddUserSettings < ActiveRecord::Migration
  def up
    add_column :users, :about, :text
    add_column :users, :default_story_locale, :string, :default => 'en'
    
    # add default locale to all users
    User.update_all(:default_story_locale => 'en')
  end

  def down
    remove_column :users, :about
    remove_column :users, :default_story_locale
  end
end
