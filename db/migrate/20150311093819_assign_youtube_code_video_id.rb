class AssignYoutubeCodeVideoId < ActiveRecord::Migration
  def up
    YoutubeTranslation.transaction do
      YoutubeTranslation.all.each {|t| t.save! }
    end
  end

  def down
    YoutubeTranslation.transaction do
      YoutubeTranslation.all.each {|t| t.save! }
    end
  end
end
