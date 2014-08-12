class AssetObserver < ActiveRecord::Observer
  
  def after_save(asset)
    # if this is a video and the file is new or has changed, add it to the to process queue
    #Rails.logger.debug "+++++++ after_save "
    asset.process_video = asset.asset_type == Asset::TYPE[:media_video] && asset.asset_updated_at_changed?
    return true
  end

  # add new video to queue to be processed
  def after_commit(asset)
    #Rails.logger.debug "+++++++ after_commit, process video = #{asset.process_video}"
    if asset.process_video
      require 'csv'
      #Rails.logger.debug "+++++++ - processing"

      queue_file = "#{Rails.root}/public/system/video_processing/to_process.csv"

      # make sure directory exists
			FileUtils.mkpath(File.dirname(queue_file))
            
      story_id = asset.video.section.story_id
      asset_id = asset.id
      path = asset.asset.url(:original, false)
      
      # append line to queue file
      CSV.open(queue_file, "a") do |csv|      
        csv << [story_id, asset_id, path]
      end
      
    end
    return true
  end
end
