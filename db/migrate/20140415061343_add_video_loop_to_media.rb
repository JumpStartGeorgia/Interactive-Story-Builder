class AddVideoLoopToMedia < ActiveRecord::Migration
  def change
    add_column :media, :video_loop, :boolean
  end
end
