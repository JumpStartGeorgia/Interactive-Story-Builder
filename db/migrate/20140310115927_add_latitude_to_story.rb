class AddLatitudeToStory < ActiveRecord::Migration
  def change
    add_column :stories, :latitude, :double
  end
end
