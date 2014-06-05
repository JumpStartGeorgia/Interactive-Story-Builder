class RescaleThumbnails < ActiveRecord::Migration
  def up
    Asset.where(:asset_type => Asset::TYPE[:story_thumbnail]).each do |as|
      as.asset.reprocess! if as.asset.exists?
    end

  end

  def down
    # do nothing
  end
end
