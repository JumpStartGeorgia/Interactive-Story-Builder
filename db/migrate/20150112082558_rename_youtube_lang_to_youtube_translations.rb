class RenameYoutubeLangToYoutubeTranslations < ActiveRecord::Migration
	def change
    	rename_table :youtube_langs, :youtube_translations
  	end
end
