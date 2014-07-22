class ApplyStoryLang < ActiveRecord::Migration
  def up
    require 'story_language'
    StoryLanguage.assign
  end

  def down
    Story.update_all(:story_locale => 'en')
  end
end
