class RemoveVideoSettingsIdFromYoutube < ActiveRecord::Migration
def change
    remove_column :youtubes, :video_settings_id
  end
end
