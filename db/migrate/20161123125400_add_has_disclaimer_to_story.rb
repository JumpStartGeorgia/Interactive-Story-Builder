class AddHasDisclaimerToStory < ActiveRecord::Migration
  def up
    add_column :stories, :has_disclaimer, :boolean, :default => true
  end

  def down
    remove_column :stories, :has_disclaimer
  end
end
