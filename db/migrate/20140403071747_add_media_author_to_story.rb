class AddMediaAuthorToStory < ActiveRecord::Migration
  def change
    add_column :stories, :media_author, :string, :limit=>255
  end
end
