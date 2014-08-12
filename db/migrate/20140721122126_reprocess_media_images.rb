class ReprocessMediaImages < ActiveRecord::Migration
  def up
    Asset.transaction do
      imgs = Asset.where(:asset_type => Asset::TYPE[:media_image])
      imgs.each_with_index do |img,index|
        puts "processing img #{index} of #{imgs.length}"
        img.asset.reprocess! if img.asset.exists?
      end
    end
  end

  def down
    # do nothing
  end
end
