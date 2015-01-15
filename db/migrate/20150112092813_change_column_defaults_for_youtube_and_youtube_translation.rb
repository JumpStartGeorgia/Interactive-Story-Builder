class ChangeColumnDefaultsForYoutubeAndYoutubeTranslation < ActiveRecord::Migration
  def up
  	change_column_default :youtubes, :fullscreen, false
  	change_column_default :youtubes, :loop, false
  	change_column_default :youtubes, :info, false
  	change_column_default :youtube_translations, :cc, true
  end

  def down
  	change_column_default :youtubes, :fullscreen, nil
  	change_column_default :youtubes, :loop, nil
  	change_column_default :youtubes, :info, nil
  	change_column_default :youtube_translations, :cc, nil
  end
end