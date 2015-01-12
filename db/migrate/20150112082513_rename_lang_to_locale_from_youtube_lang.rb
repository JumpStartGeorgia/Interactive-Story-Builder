class RenameLangToLocaleFromYoutubeLang < ActiveRecord::Migration
	def change
    	rename_column :youtube_langs, :lang, :locale
  	end
end