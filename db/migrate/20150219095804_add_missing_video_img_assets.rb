class AddMissingVideoImgAssets < ActiveRecord::Migration
  def up
    Asset.transaction do 
      # get all videos records that are clones
      videos = Asset.where('asset_type = ? and asset_clone_id is not null', Asset::TYPE[:media_video])

      if videos.present?
        videos.each do |video|
          puts "video = #{video.inspect}"
          # see if image record exists with this item_id
          image = Asset.where(['asset_type = ? and asset_clone_id is not null and item_id = ?', Asset::TYPE[:media_image], video.item_id])
          if image.blank?
            puts "- img does not exist!"
            # did not find image record so need to create it
            # get id of image record to clone            
            clone = Asset.where(['asset_type = ? and item_id = ?', Asset::TYPE[:media_image], video.asset_clone.item_id])

            if clone.present?
              puts "clone img = #{clone.inspect}"
              Asset.create(asset_type: Asset::TYPE[:media_image], item_id: video.item_id, 
                          asset_clone_id: clone.first.id, story_id: video.story_id)
            end
          end
        end
      end
    end
  end

  def down
    # do nothing
  end
end
