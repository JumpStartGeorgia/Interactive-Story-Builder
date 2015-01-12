class DropTableVideoSettings < ActiveRecord::Migration
	def change
    	drop_table :video_settings
  	end
end
