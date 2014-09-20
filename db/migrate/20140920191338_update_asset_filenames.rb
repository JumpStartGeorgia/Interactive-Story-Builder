class UpdateAssetFilenames < ActiveRecord::Migration
  def up
    # for audio, media and slideshow assets in a story, update the file names
    # - before, if same file was uploaded multiple times in same story, there was only one version of file
    #   so if file was deleted in one place, it was deleted for all other places.
    # - now, need to append asset id in from of file name and make unique
    # - if file is used multiple times in story, make new copy for each time it is used
    Story.transaction do 
      Story.select('id').each do |story|
        ###############################
        # check for audio in sections
        file_names = story.sections.map{|x| x.asset.present? ? [x.asset.id, x.asset.asset_file_name] : [nil,nil]}
        file_names.delete([nil,nil])
        # if there is a repeat in file name, than there is work to do!
        if file_names.map{|x| x[1]}.length != file_names.map{|x| x[1]}.uniq.length
          # get count of each file name
          file_name_counts = Hash.new(0)
          file_names.each {|x| file_name_counts[x[1]] += 1}
          # pull out names with counts > 1
          file_names_to_fix = []
          file_name_counts.values.each_with_index do |value, index|
            if value > 1
              file_names_to_fix << file_name_counts.keys[index]
            end
          end
          file_names_to_fix.each do |file_name|
            # was path: /system/places/audio/story_id/file_name
            # change to path: /system/places/audio/story_id/id__file_name
            # make sure file exists before continuing
            if File.exists?("#{Rails.root}/public/system/places/audio/#{story.id}/#{file_name}")
              assets = file_names.select{|x| x[1] == file_name}
              (0..assets.length-1).each do |index|
                # if this is the last item in list, just add the id to the file name
                # otherwise, make a copy of the file and add id to file name
                if index == assets.length-1
                  FileUtils.mv "#{Rails.root}/public/system/places/audio/#{story.id}/#{file_name}",
                               "#{Rails.root}/public/system/places/audio/#{story.id}/#{assets[index][0]}__#{file_name}" 
                else
                  FileUtils.cp "#{Rails.root}/public/system/places/audio/#{story.id}/#{file_name}",
                               "#{Rails.root}/public/system/places/audio/#{story.id}/#{assets[index][0]}__#{file_name}" 
                end
              end
            end
          end
        end


        ###############################
        # check for slide show sections
        file_names = story.sections.select{|x| x.type_id == Section::TYPE[:slideshow]}
                      .map{|x| x.slideshow.assets.map{|y| [y.id, y.asset_file_name]}}.flatten(1)
        # if there is a repeat in file name, than there is work to do!
        if file_names.map{|x| x[1]}.length != file_names.map{|x| x[1]}.uniq.length
          # get count of each file name
          file_name_counts = Hash.new(0)
          file_names.each {|x| file_name_counts[x[1]] += 1}
          # pull out names with counts > 1
          file_names_to_fix = []
          file_name_counts.values.each_with_index do |value, index|
            if value > 1
              file_names_to_fix << file_name_counts.keys[index]
            end
          end

          styles = ['original', 'mobile_640', 'mobile_1024', 'slideshow', 'thumbnail', 'thumbnail_preview']
          file_names_to_fix.each do |file_name|
            # was path: /system/places/slideshow/story_id/style/file_name
            # change to path: /system/places/slideshow/story_id/style/id__file_name
            # make sure file exists before continuing
              assets = file_names.select{|x| x[1] == file_name}
              (0..assets.length-1).each do |index|
                # fix the image for each style
                styles.each do |style|
                  if File.exists?("#{Rails.root}/public/system/places/slideshow/#{story.id}/#{style}/#{file_name}")
                    # if this is the last item in list, just add the id to the file name
                    # otherwise, make a copy of the file and add id to file name
                    if index == assets.length-1
                      FileUtils.mv "#{Rails.root}/public/system/places/slideshow/#{story.id}/#{style}/#{file_name}",
                                   "#{Rails.root}/public/system/places/slideshow/#{story.id}/#{style}/#{assets[index][0]}__#{file_name}" 
                    else
                      FileUtils.cp "#{Rails.root}/public/system/places/slideshow/#{story.id}/#{style}/#{file_name}",
                                   "#{Rails.root}/public/system/places/slideshow/#{story.id}/#{style}/#{assets[index][0]}__#{file_name}" 
                    end
                  end
                end
              end
            end
          end  
        end     

        ###############################
        # check for media sections with images
        file_names = story.sections.select{|x| x.type_id == Section::TYPE[:media]}
                      .map{|x| x.media}.flatten.select{|x| x.media_type == Medium::TYPE[:image]}
                      .map{|x| x.image.present? ? [x.image.id, x.image.asset_file_name] : [nil,nil]}
        file_names.delete([nil,nil])
        # if there is a repeat in file name, than there is work to do!
        if file_names.map{|x| x[1]}.length != file_names.map{|x| x[1]}.uniq.length
          # get count of each file name
          file_name_counts = Hash.new(0)
          file_names.each {|x| file_name_counts[x[1]] += 1}
          # pull out names with counts > 1
          file_names_to_fix = []
          file_name_counts.values.each_with_index do |value, index|
            if value > 1
              file_names_to_fix << file_name_counts.keys[index]
            end
          end

          styles = ['original', 'mobile_640', 'mobile_1024', 'fullscreen']
          file_names_to_fix.each do |file_name|
            # was path: /system/places/images/story_id/style/file_name
            # change to path: /system/places/images/story_id/style/id__file_name
            # make sure file exists before continuing
              assets = file_names.select{|x| x[1] == file_name}
              (0..assets.length-1).each do |index|
                # fix the image for each style
                styles.each do |style|
                  if File.exists?("#{Rails.root}/public/system/places/images/#{story.id}/#{style}/#{file_name}")
                    # if this is the last item in list, just add the id to the file name
                    # otherwise, make a copy of the file and add id to file name
                    if index == assets.length-1
                      FileUtils.mv "#{Rails.root}/public/system/places/images/#{story.id}/#{style}/#{file_name}",
                                   "#{Rails.root}/public/system/places/images/#{story.id}/#{style}/#{assets[index][0]}__#{file_name}" 
                    else
                      FileUtils.cp "#{Rails.root}/public/system/places/images/#{story.id}/#{style}/#{file_name}", "#{Rails.root}/public/system/places/images/#{story.id}/#{style}/#{assets[index][0]}__#{file_name}" 
                    end
                  end
                end
              end
            end
          end
        end

      end   
    end
  end


  def down
    Story.transaction do 
      Story.select('id').each do |story|
        ###############################
        # check for audio in sections
        file_names = story.sections.map{|x| x.asset.present? ? [x.asset.id, x.asset.asset_file_name] : [nil,nil]}
        file_names.delete([nil,nil])
        # if there is a repeat in file name, than there is work to do!
        if file_names.map{|x| x[1]}.length != file_names.map{|x| x[1]}.uniq.length
          # get count of each file name
          file_name_counts = Hash.new(0)
          file_names.each {|x| file_name_counts[x[1]] += 1}
          # pull out names with counts > 1
          file_names_to_fix = []
          file_name_counts.values.each_with_index do |value, index|
            if value > 1
              file_names_to_fix << file_name_counts.keys[index]
            end
          end
          file_names_to_fix.each do |file_name|
            # was path: /system/places/audio/story_id/id__file_name
            # change to path: /system/places/audio/story_id/file_name
            assets = file_names.select{|x| x[1] == file_name}
            (0..assets.length-1).each do |index|
              if File.exists?("#{Rails.root}/public/system/places/audio/#{story.id}/#{assets[index][0]}__#{file_name}")
                # if this is the last item in list, just remove the id from the file name
                # otherwise, delete the file
                if index == assets.length-1
                  FileUtils.mv "#{Rails.root}/public/system/places/audio/#{story.id}/#{assets[index][0]}__#{file_name}", 
                                "#{Rails.root}/public/system/places/audio/#{story.id}/#{file_name}"
                else
                  FileUtils.remove_file "#{Rails.root}/public/system/places/audio/#{story.id}/#{assets[index][0]}__#{file_name}" 
                end
              end
            end
          end
        end

        ###############################
        # check for slide show sections
        file_names = story.sections.select{|x| x.type_id == Section::TYPE[:slideshow]}
                      .map{|x| x.slideshow.assets.map{|y| [y.id, y.asset_file_name]}}.flatten(1)
        # if there is a repeat in file name, than there is work to do!
        if file_names.map{|x| x[1]}.length != file_names.map{|x| x[1]}.uniq.length
          # get count of each file name
          file_name_counts = Hash.new(0)
          file_names.each {|x| file_name_counts[x[1]] += 1}
          # pull out names with counts > 1
          file_names_to_fix = []
          file_name_counts.values.each_with_index do |value, index|
            if value > 1
              file_names_to_fix << file_name_counts.keys[index]
            end
          end

          styles = ['original', 'mobile_640', 'mobile_1024', 'slideshow', 'thumbnail', 'thumbnail_preview']
          file_names_to_fix.each do |file_name|
            # was path: /system/places/slideshow/story_id/style/id__file_name
            # change to path: /system/places/slideshow/story_id/style/file_name
            # make sure file exists before continuing
              assets = file_names.select{|x| x[1] == file_name}
              (0..assets.length-1).each do |index|
                # fix the image for each style
                styles.each do |style|
                  if File.exists?("#{Rails.root}/public/system/places/slideshow/#{story.id}/#{style}/#{assets[index][0]}__#{file_name}")
                    # if this is the last item in list, just remove the id from the file name
                    # otherwise, delete the file
                    if index == assets.length-1
                      FileUtils.mv "#{Rails.root}/public/system/places/slideshow/#{story.id}/#{style}/#{assets[index][0]}__#{file_name}", 
                                    "#{Rails.root}/public/system/places/slideshow/#{story.id}/#{style}/#{file_name}"
                    else
                      FileUtils.remove_file "#{Rails.root}/public/system/places/slideshow/#{story.id}/#{style}/#{assets[index][0]}__#{file_name}" 
                    end
                  end
                end
              end
            end
          end  
        end     

        ###############################
        # check for media sections with images
        file_names = story.sections.select{|x| x.type_id == Section::TYPE[:media]}
                      .map{|x| x.media}.flatten.select{|x| x.media_type == Medium::TYPE[:image]}
                      .map{|x| x.image.present? ? [x.image.id, x.image.asset_file_name] : [nil,nil]}
        file_names.delete([nil,nil])
        # if there is a repeat in file name, than there is work to do!
        if file_names.map{|x| x[1]}.length != file_names.map{|x| x[1]}.uniq.length
          # get count of each file name
          file_name_counts = Hash.new(0)
          file_names.each {|x| file_name_counts[x[1]] += 1}
          # pull out names with counts > 1
          file_names_to_fix = []
          file_name_counts.values.each_with_index do |value, index|
            if value > 1
              file_names_to_fix << file_name_counts.keys[index]
            end
          end

          styles = ['original', 'mobile_640', 'mobile_1024', 'fullscreen']
          file_names_to_fix.each do |file_name|
            # was path: /system/places/images/story_id/style/file_name
            # change to path: /system/places/images/story_id/style/id__file_name
            # make sure file exists before continuing
              assets = file_names.select{|x| x[1] == file_name}
              (0..assets.length-1).each do |index|
                # fix the image for each style
                styles.each do |style|
                  if File.exists?("#{Rails.root}/public/system/places/images/#{story.id}/#{style}/#{assets[index][0]}__#{file_name}")
                    # if this is the last item in list, just remove the id from the file name
                    # otherwise, delete the file
                    if index == assets.length-1
                      FileUtils.mv "#{Rails.root}/public/system/places/images/#{story.id}/#{style}/#{assets[index][0]}__#{file_name}", 
                                    "#{Rails.root}/public/system/places/images/#{story.id}/#{style}/#{file_name}",
                                   
                    else
                      FileUtils.remove_file "#{Rails.root}/public/system/places/images/#{story.id}/#{style}/#{assets[index][0]}__#{file_name}" 
                    end
                  end
                end
              end
            end
          end
        end



      end   
    end
  end

end
