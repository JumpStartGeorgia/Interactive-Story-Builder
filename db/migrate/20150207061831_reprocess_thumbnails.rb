class ReprocessThumbnails < ActiveRecord::Migration
  def up
    Asset.where(:asset_type => Asset::TYPE[:story_thumbnail]).each do |asset|
      puts "asset id #{asset.id}"
      asset.asset.reprocess! if asset.asset.exists?
    end
  end

  def down
    # do nothing
  end
end
