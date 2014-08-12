class UpdateContentImagePath < ActiveRecord::Migration
  def up
    Content.transaction do 
      records = Content.where("content like '%/system/places/images%'")
      if records.present?
        puts "there are #{records.length} content records that need to have the image path updated"
        records.each do |record|
          puts "-------------"
          puts "updating content id #{record.id}"
          record.content.gsub!(/\/system\/places\/images\/[\d]+\/original\//) {|y| y.gsub('/original/', '/mobile_640/')}    
          record.content_will_change!
          record.save
          
          # now reprocess the images to make the mobile versions the correct size
          # - get all images to process from this record
          images = record.content.scan(/src="(.*?)"/)
          if images.present?
            puts "- #{images.length} images to process"
            # - return format of scan is: [[image path], [image_path], etc]
            # - image path format is: ../../../system/places/images/[story_id]/mobile_640/[file_name]
            # - pull out story id and file name for each image
            # - get original image and then parse
            images.each do |img|
              paths = img.first.split('/')
              story_id = paths[6]
              file_name = paths[8]
              if story_id.present? && file_name.present?
                puts "- for story_id #{story_id}, processing image: #{file_name}"
                original_path = "#{Rails.root}/public/system/places/images/#{story_id}/original/#{file_name}"
                mobile_640_path = "#{Rails.root}/public/system/places/images/#{story_id}/mobile_640/#{file_name}"
                mobile_1024_path = "#{Rails.root}/public/system/places/images/#{story_id}/mobile_1024/#{file_name}"
                if File.exists?(original_path)
                  Subexec.run "convert #{original_path} -resize '640x427>' #{mobile_640_path}"                
                  Subexec.run "convert #{original_path} -resize '1024x623>' #{mobile_1024_path}"     
                end              
              end            
            end
          end
        end
      end
    end
  end

  def down
    Content.transaction do 
      records = Content.where("content like '%/system/places/images%'")
      if records.present?
        records.each do |record|
          record.content.gsub!(/\/system\/places\/images\/[\d]+\/mobile_640\//) {|y| y.gsub('/mobile_640/', '/original/')}    
          record.content_will_change!
          record.save
        end
      end
    end
  end
end
