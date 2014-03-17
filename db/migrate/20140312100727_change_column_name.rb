class ChangeColumnName < ActiveRecord::Migration
  def change
		rename_column :sections, :type_id, :type
		rename_column :sections, :audio, :audio_path
	end
end
