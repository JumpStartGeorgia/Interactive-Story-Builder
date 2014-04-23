class AddThumbnaiToStory < ActiveRecord::Migration
  def change
    add_column :stories, :thumbnail, :integer
  end
end
