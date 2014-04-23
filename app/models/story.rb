class Story < ActiveRecord::Base
	has_many :sections, :order => 'position', dependent: :destroy
	has_and_belongs_to_many :users
	belongs_to :user
	validates :title, length: { maximum: 100 }
	validates :author, :presence => true, length: { maximum: 255 }
	validates :media_author, length: { maximum: 255 }
	attr_accessor :was_publishing

 	after_find :publishing_done?
	before_save :publish_date
	 
  scope :is_published, where(:published => true)
  
	amoeba do
		enable
		clone [:sections]
	end

  def self.can_edit?(story_id, user_id)
    x = select('id').where(:id => story_id).editable_user(user_id)  
    return x.present?
  end

  def self.editable_user(user_id)
    where("stories.user_id = :id or stories.id in ( select story_id from stories_users t where t.user_id = :id )",
      :id => user_id)
  end

	def self.fullsection(story_id)
		includes(sections: [:media,:content])
		.where(stories: {id: story_id})
		.first
	end


	def publishing_done?
		self.was_publishing = self.has_attribute?(:published) ? self.published : nil		
	end


	def publish_date		
  	  if  self.was_publishing != self.published && self.published?
  	  	self.published_at = Time.now
  	  end     
  	end

end
