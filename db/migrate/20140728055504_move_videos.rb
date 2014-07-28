class MoveVideos < ActiveRecord::Migration
  def up
    # move all videos into original sub-folder
    
    path = "#{Rails.root}/public/system/places/video/"
    original = "/original"
    poster = "/poster"
    
    # for each folder in path, create original folder and move all files into it
    Dir.new(path).each do |dir|
      if !(['.', '..'].include?(dir))
        puts dir

        video_path = "#{path}#{dir}"
        original_path = video_path + original
        poster_path = video_path + poster

        # create folder if not exist
        FileUtils.mkdir(original_path) if !Dir.exists?(original_path)
        FileUtils.mkdir(poster_path) if !Dir.exists?(poster_path)
        
        # move files
        # - movies
        FileUtils.mv(Dir.glob("#{video_path}/*.mp4"), original_path)
        # - images
        FileUtils.mv(Dir.glob("#{video_path}/*.jpg"), poster_path)
      end
    end
    
  end

  def down
    # move all videos to root

    path = "#{Rails.root}/public/system/places/video/"
    original = "/original"
    poster = "/poster"

    # for each folder in path, move files from original folder to root
    Dir.new(path).each do |dir|
      if !(['.', '..'].include?(dir))
        puts dir

        video_path = "#{path}#{dir}"
        original_path = video_path + original
        poster_path = video_path + poster

        # move files
        # - movies
        FileUtils.mv(Dir.glob("#{original_path}/*.mp4"), video_path)
        # - images
        FileUtils.mv(Dir.glob("#{poster_path}/*.jpg"), video_path)
        
        # delete original folder
        FileUtils.rmdir(original_path)
        FileUtils.rmdir(poster_path)
      end
    end
  end
end
