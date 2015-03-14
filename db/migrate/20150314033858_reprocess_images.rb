class ReprocessImages < ActiveRecord::Migration
  def up
    images = [Asset::TYPE[:story_thumbnail], Asset::TYPE[:media_image], 
              Asset::TYPE[:slideshow_image], Asset::TYPE[:user_avatar], 
              Asset::TYPE[:author_avatar], Asset::TYPE[:infographic], 
              Asset::TYPE[:infographic_dataset]]

    assets = Asset.where(asset_type: images, asset_clone_id: nil)
    puts "---------------"
    puts "#{assets.length} assets to reprocess!"
    puts "---------------"

    assets.each_with_index do |asset, index|
      puts "#{assets.length-index} assets to process!" if index % 10 == 0

      asset.asset.reprocess! if asset.asset.exists?
    end
  end

  def down
    # do nothing
  end
end
