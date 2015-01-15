class AddFullscreenAndLoopAndInfoToYoutube < ActiveRecord::Migration
  def change
    add_column :youtubes, :fullscreen, :boolean
    add_column :youtubes, :loop, :boolean
    add_column :youtubes, :info, :boolean
  end
end
