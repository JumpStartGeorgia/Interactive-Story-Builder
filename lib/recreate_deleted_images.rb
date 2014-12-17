module RecreateDeletedImages

  ## The clone update released on 12/16 had a bug 
  ## that was causing the video images of the original story
  ## to be deleted.
  ## This script recreates the images for video media records if they do not exist

  def self.restore
    count = 0
    Medium.transaction do
      Medium.where(:media_type => Medium::TYPE[:video]).each do |media|
        if !media.image_exists? 
          puts "@@@@@@ media id #{media.id} (story #{media.section.story_id}) is missing image"
          
          # see if poster exists
          image_file = "#{Rails.root}/public#{media.video.asset.url(:poster, false)}"
          puts "@@@@@@@@ checking for existing post at: #{image_file}"
          if File.exists?(image_file)
            puts "@@@@@@@@ file exists, saving!"
            File.open(image_file) do |f|
              # if image does not exist, create it
              # else, update it
              if media.image_exists?
                puts "@@@@@@@@ -> updating existing video image record"
                media.image.is_video_image = true
                media.image.asset = f
                media.image.save            
              else
                puts "@@@@@@@@ -> adding missing image record"
                media.create_image(:asset_type => Asset::TYPE[:media_image], :is_video_image => true, :asset => f)
              end
              count += 1
            end 
          end
        end
      end
    end

    puts "@@@@@@ #{count} image records were restored"

    return true
  end




end
