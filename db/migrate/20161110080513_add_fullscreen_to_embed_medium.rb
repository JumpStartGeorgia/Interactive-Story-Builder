class AddFullscreenToEmbedMedium < ActiveRecord::Migration
  def up
    add_column :embed_media, :fullscreen, :boolean, :default => false
  end

  def down
    remove_column :embed_media, :fullscreen
  end
end
