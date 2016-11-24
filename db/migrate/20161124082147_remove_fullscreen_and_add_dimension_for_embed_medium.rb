class RemoveFullscreenAndAddDimensionForEmbedMedium < ActiveRecord::Migration
  def up
    add_column :embed_media, :dimension, :integer, :limit => 1, :default => 0
    EmbedMedium.where("fullscreen = 1").update_all(dimension: 1)
    remove_column :embed_media, :fullscreen
  end
  def down
    add_column :embed_media, :fullscreen, :boolean, :default => false
    EmbedMedium.where("dimension = 1").update_all(fullscreen: true)
    remove_column :embed_media, :dimension
  end
end
