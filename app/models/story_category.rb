class StoryCategory < ActiveRecord::Base
	belongs_to :story
	belongs_to :category

	attr_accessible :story_id, :category_id

  validates :story_id, :category_id, :presence => true
end
