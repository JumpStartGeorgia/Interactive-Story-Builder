require 'clean_up_video_folder'
namespace :video_files do

  desc "Get a count of the number of orphan processed videos"
  task :count_orphan_files => [:environment] do
    CleanUpVideoFolder.find_files
  end

  desc "Delete the orphan processed videos"
  task :delete_orphan_files => [:environment] do
    CleanUpVideoFolder.delete_files
  end
end
