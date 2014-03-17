class AddLongitudeToStory < ActiveRecord::Migration
  def change
    add_column :stories, :longitude, :double
  end
end
