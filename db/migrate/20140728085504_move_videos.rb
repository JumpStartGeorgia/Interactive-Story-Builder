class MoveVideos < ActiveRecord::Migration
  def up
    # move all videos at root of sub-folder into processed folder if already in original folder
    # - else move into original folder so can be processed
    # move all images at root of sub-folder into poster folder
    
    path = "#{Rails.root}/public/system/places/video/"
    original = "/original"
    poster = "/poster"
    processed = "/processed"
    
    Dir.new(path).each do |dir|
      if !(['.', '..'].include?(dir))
        puts dir

        video_path = "#{path}#{dir}"
        original_path = video_path + original
        poster_path = video_path + poster
        processed_path = video_path + processed

        # create folder if not exist
        FileUtils.mkdir(original_path) if !Dir.exists?(original_path)
        FileUtils.mkdir(poster_path) if !Dir.exists?(poster_path)
        FileUtils.mkdir(processed_path) if !Dir.exists?(processed_path)
        
        # move files
        # - poster images
        FileUtils.mv(Dir.glob("#{video_path}/*.jpg"), poster_path)
        # if file is already in original folder
        # - assume file at root is processed
        # - do not move file into original
        Dir.glob("#{video_path}/*.mp4").each do |video|
          puts "- #{video}"
          if File.exists?(File.join(original_path, File.basename(video)))
            puts "-> moving to processed folder"
            # - move processed video
            FileUtils.mv(video, processed_path)
          else
            puts "-> moving to original folder"

            # if this is dev machine, go ahead and move movies into processed folder
            # so do not have to process all of them
            if Rails.env.development?
              # - move processed video
              FileUtils.cp(video, processed_path)
            end

            # - file is not processed yet
            # - move original video
            FileUtils.mv(video, original_path)
          end
        end
      end
    end
    
  end

  def down
    # move all files to root
    # - leave original folder as is
    # - move all files in processed to root, 
    #   then check original folder for any files not processed yet

    path = "#{Rails.root}/public/system/places/video/"
    original = "/original"
    poster = "/poster"
    processed = "/processed"

    # for each folder in path, move files from original folder to root
    Dir.new(path).each do |dir|
      if !(['.', '..'].include?(dir))
        puts dir

        video_path = "#{path}#{dir}"
        original_path = video_path + original
        poster_path = video_path + poster
        processed_path = video_path + processed

        # move files
        # - poster images
        FileUtils.mv(Dir.glob("#{poster_path}/*.jpg"), video_path)
        # if video is in processed folder, move it to root
        # else move video from original to root
        # - move processed movies
        FileUtils.mv(Dir.glob("#{processed_path}/*.mp4"), video_path)
        # now check original folder for any files not already at root
        Dir.glob("#{original_path}/*.mp4").each do |video|
          puts "- original video: #{video}"
          if !(File.exists?(video.gsub(original, '')))
            puts "-> moving to root"
            FileUtils.mv(video, video_path)
          end
        end                
        
        # delete original folder
        FileUtils.rmdir(poster_path)
        FileUtils.rmdir(processed_path)
      end
    end
  end
  
end
