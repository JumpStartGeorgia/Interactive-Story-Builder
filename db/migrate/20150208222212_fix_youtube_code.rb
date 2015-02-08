class FixYoutubeCode < ActiveRecord::Migration
  def up
    YoutubeTranslation.transaction do 
      YoutubeTranslation.all.each do |video|
        video.code.gsub!('&shoswinfo=0', '&showinfo=0')
        video.save
      end 
    end
  end

  def down
    YoutubeTranslation.transaction do 
      YoutubeTranslation.all.each do |video|
        video.code.gsub!('&showinfo=0', '&shoswinfo=0')
        video.save
      end 
    end
  end
end
