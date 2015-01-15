class StoryTheme < ActiveRecord::Base
  belongs_to :story
  belongs_to :theme

  attr_accessible :story_id, :theme_id

  validates :story_id, :theme_id, :presence => true
  
end
