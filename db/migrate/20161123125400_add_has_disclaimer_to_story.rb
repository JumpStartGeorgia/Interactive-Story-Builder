class AddHasDisclaimerToStory < ActiveRecord::Migration
  def up
    add_column :stories, :has_disclaimer, :boolean, :default => true
    Story.update_all has_disclaimer: false
  end

  def down
    remove_column :stories, :has_disclaimer
  end
end
