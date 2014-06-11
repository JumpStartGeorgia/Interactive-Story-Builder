namespace :story do
  desc "Assign a language to all stories on file"
  task :assign_language => [:environment] do
    require 'story_language'
    StoryLanguage.assign
  end
end
