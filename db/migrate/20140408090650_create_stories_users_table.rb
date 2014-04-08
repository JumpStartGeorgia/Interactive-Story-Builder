class CreateStoriesUsersTable < ActiveRecord::Migration
  def up
  	 create_table :stories_users do |t|
      t.integer :story_id
      t.integer :user_id
    end
  end

  def down
  	drop_table :stories_users
  end
end
