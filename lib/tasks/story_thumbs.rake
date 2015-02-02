namespace :story do
desc "Process Story Thumbnails"
task :thumbnail_process => [:environment] do
	Asset.where(:asset_type => Asset::TYPE[:story_thumbnail]).each {|as| 
		if (as.asset.present? && as.file.exists?) 
			as.asset.reprocess!
	 	end
	}
end
end