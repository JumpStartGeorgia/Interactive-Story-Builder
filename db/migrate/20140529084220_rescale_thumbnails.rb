class RescaleThumbnails < ActiveRecord::Migration
  def up
    Story.all.each do |s|
      s.asset.asset.reprocess! if s.asset_exists?
    end

  end

  def down
    # do nothing
  end
end
