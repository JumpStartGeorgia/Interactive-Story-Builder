class AssignYoutubeCodeVideoId < ActiveRecord::Migration
  def up
    YoutubeTranslation.all.each {|t| t.save! }
  end

  def down
   YoutubeTranslation.all.each {|t| t.save! }
  end
end
