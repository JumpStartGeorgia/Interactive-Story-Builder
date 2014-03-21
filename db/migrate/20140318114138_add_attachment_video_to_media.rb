class AddAttachmentVideoToMedia < ActiveRecord::Migration
  def self.up
    change_table :media do |t|
      t.attachment :video
    end
  end

  def self.down
    drop_attached_file :media, :video
  end
end
