class RemoveAudioPathFromSection < ActiveRecord::Migration
  def up
    remove_column :sections, :audio_path
  end

  def down
    add_column :sections, :audio_path, :string
  end
end
