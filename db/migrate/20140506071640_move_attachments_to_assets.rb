class MoveAttachmentsToAssets < ActiveRecord::Migration
  def up
    Asset.transaction do
      # story thumbnails
      count = 0
      Story.where('thumbnail_file_name_old is not null').each do |item|
        count += 1
        Asset.create(
          :item_id => item.id, 
          :asset_type => Asset::TYPE[:story_thumbnail],
          :asset_file_name => item.thumbnail_file_name_old,
          :asset_content_type => item.thumbnail_content_type_old,
          :asset_file_size => item.thumbnail_file_size_old,
          :asset_updated_at => item.thumbnail_updated_at_old
        )                    
      end
      puts "moved #{count} story thumbnail records"
      
      # section audio
      count = 0
      Section.where('audio_file_name_old is not null').each do |item|
        count += 1
        Asset.create(
          :item_id => item.id, 
          :asset_type => Asset::TYPE[:section_audio],
          :asset_file_name => item.audio_file_name_old,
          :asset_content_type => item.audio_content_type_old,
          :asset_file_size => item.audio_file_size_old,
          :asset_updated_at => item.audio_updated_at_old
        )                    
      end
      puts "moved #{count} section audio records"
      
      # media images
      count = 0
      Medium.where('image_file_name_old is not null').each do |item|
        count += 1
        Asset.create(
          :item_id => item.id, 
          :asset_type => Asset::TYPE[:media_image],
          :asset_file_name => item.image_file_name_old,
          :asset_content_type => item.image_content_type_old,
          :asset_file_size => item.image_file_size_old,
          :asset_updated_at => item.image_updated_at_old
        )                    
      end
      puts "moved #{count} media image records"
      
      # media videos    
      count = 0
      Medium.where('video_file_name_old is not null').each do |item|
        count += 1
        Asset.create(
          :item_id => item.id, 
          :asset_type => Asset::TYPE[:media_video],
          :asset_file_name => item.video_file_name_old,
          :asset_content_type => item.video_content_type_old,
          :asset_file_size => item.video_file_size_old,
          :asset_updated_at => item.video_updated_at_old
        )                    
      end
      puts "moved #{count} media video records"
    
    end
  end

  def down
    Asset.destroy_all
  end
end
