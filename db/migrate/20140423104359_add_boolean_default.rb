class AddBooleanDefault < ActiveRecord::Migration
  def up
    change_column :media, :video_loop, :boolean, :default => true
    change_column :sections, :has_marker, :boolean, :default => true
    change_column :stories, :published, :boolean, :default => false
  end
  def down
    change_column :media, :video_loop, :boolean, :default => true
    change_column :sections, :has_marker, :boolean, :default => nil
    change_column :stories, :published, :boolean, :default => nil
  end
end
