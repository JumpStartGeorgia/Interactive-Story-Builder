class StoryAuthor < ActiveRecord::Base
  
  belongs_to :story
  belongs_to :author

  attr_accessible :author_id, :story_id
end
