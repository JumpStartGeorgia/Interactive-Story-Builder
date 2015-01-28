class UpdateStoryUsers < ActiveRecord::Migration
  def change
    rename_table :stories_users, :story_users

    add_column :story_users, :role, :integer, :default => 0, :limit => 1
    add_column :story_users, :translation_locales, :string

    add_timestamps(:story_users)

    add_index :story_users, :role
    add_index :story_users, :created_at

    add_column :invitations, :role, :integer, :default => 0, :limit => 1
    add_column :invitations, :translation_locales, :string

  end

end
