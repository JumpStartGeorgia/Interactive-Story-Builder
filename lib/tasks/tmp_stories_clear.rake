namespace :story do
	desc "Clear tmp/stories folder of generated files with last access an hour ago"
	task :tmp_stories_clear => [:environment] do
	   	rootPath = "#{Rails.root}/tmp/stories";	   	
		Dir.foreach(rootPath) {|f|
			if f != "." && f != ".."
				path = rootPath +"/"+ f
				if File.atime(path) < DateTime.now - 1.hour
					if File.file?(path)
						puts "File #{f} was removed at #{DateTime.now}" 
						FileUtils.remove_file("#{path}",true)  
					elsif File.directory?(path)
						puts "Directory #{f} was removed at #{DateTime.now}"
					 	FileUtils.remove_dir(path,true)  
					end
				end	
			end
	  	}
	end
end
