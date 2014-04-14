class AddAttachmentAudioToSections < ActiveRecord::Migration
  def self.up
    change_table :sections do |t|
      t.attachment :audio
    end
  end

  def self.down
    drop_attached_file :sections, :audio
  end
end
