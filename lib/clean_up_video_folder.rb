module CleanUpVideoFolder
  @video_path = "#{Rails.root}/public/system/places/video/"

  # find out how many files are likes this and how much space they take up
  def self.find_files
    files = get_files

    if files.present?
      total_size = ((files.map{|x| x[:size]}.sum) / (1024.0 * 1024.0)).round(2)
      puts "> There are #{files.length} orphan processed video files with a size of #{total_size}MBs."
    else
      puts '> There are no orphan processed video files!'
    end

  end

  # remove the orphaned files
  def self.delete_files
    files = get_files

    if files.present?
      total_size = ((files.map{|x| x[:size]}.sum) / (1024.0 * 1024.0)).round(2)
      puts "> There are #{files.length} orphan processed video files with a size of #{total_size}MBs that will be deleted."

      deleted_count = 0
      files.map{|x| x[:file]}.each do |file|
        deleted_count += File.delete(file)
      end
      puts ">> #{deleted_count} files were deleted."

    else
      puts '> There are no orphan processed video files!'
    end
  end


  private

  def self.get_files
    files = []
    # make sure the path exists
    if Dir.exists?(@video_path)
      # go through each story folder
      Dir.open(@video_path).each do |story_id|
        story_path = @video_path + story_id
        # look for videos in processed that are orphans
        proccessed_files = Dir.glob(story_path + '/processed/*').map{|x| File.basename(x)}
        original_files = Dir.glob(story_path + '/original/*').map{|x| File.basename(x)}
        orphan = proccessed_files - original_files

        if orphan.present?
          # found orphaned files -> record them
          orphan.each do |f|
            path = story_path + '/processed/' + f
            files << {file: path, size: File.size(path)}
          end
        end
      end
    end
    return files
  end

end
