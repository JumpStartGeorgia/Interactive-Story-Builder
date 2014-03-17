class AddAttachmentImageToMedia < ActiveRecord::Migration
  def self.up
    change_table :media do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :media, :image
  end
end
