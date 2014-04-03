class Story < ActiveRecord::Base
	 has_many :sections, :order => 'position'
	 validates :title, length: { maximum: 100 }
	 validates :author, :presence => true, length: { maximum: 255 }
     validates :media_author, length: { maximum: 255 }

	 
	 def self.fullsection(story_id)
 		includes(sections: [:media,:content])
 		.where(stories: {id: story_id})
 		.first
	 end
end
