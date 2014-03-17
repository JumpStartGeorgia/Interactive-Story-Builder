class Story < ActiveRecord::Base
	 has_many :sections
	 validates :title, length: { maximum: 100 }
	 validates :author, length: { maximum: 32 }
	 def self.fullsection(story_id)
 		includes(sections: [:media,:content])
 		.where(stories: {id: story_id})
 		.first
	 end
end
