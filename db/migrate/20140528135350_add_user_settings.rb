class AddUserSettings < ActiveRecord::Migration
  def up
    add_column :users, :about, :text
    add_column :users, :default_story_locale, :string, :default => 'en'
    add_column :users, :permalink, :string
    add_index :users, :permalink
    
    # add default locale and permalink to all users
    User.transaction do 
      User.all.each do |user|
        user.default_story_locale = 'en'
        user.generate_permalink!
        user.save 
      end
    end
  end

  def down
    remove_column :users, :about
    remove_column :users, :default_story_locale
    remove_column :users, :permalink
  end
end
