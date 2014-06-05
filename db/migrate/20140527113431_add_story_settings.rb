class AddStorySettings < ActiveRecord::Migration
  def up
    add_column :stories, :about, :text
    add_column :stories, :publish_home_page, :boolean, :default => true
    add_column :stories, :staff_pick, :boolean, :default => false
    add_index :stories, [:publish_home_page, :staff_pick]

    # make all published stories show up on front page
    Story.is_published.update_all(:publish_home_page => true)
  end

  def down
    remove_index :stories, [:publish_home_page, :staff_pick]
    remove_column :stories, :about
    remove_column :stories, :publish_home_page
    remove_column :stories, :staff_pick
  end
end
