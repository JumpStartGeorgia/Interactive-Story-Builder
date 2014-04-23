class AddAttachmentThumbnailToStories < ActiveRecord::Migration
  def self.up
    change_table :stories do |t|
      t.attachment :thumbnail
    end
  end

  def self.down
    drop_attached_file :stories, :thumbnail
  end
end
