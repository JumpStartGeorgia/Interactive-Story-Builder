class AddPublishedAndPublishedToStory < ActiveRecord::Migration
  def change
    add_column :stories, :published, :boolean
    add_column :stories, :published_at, :datetime
  end
end
