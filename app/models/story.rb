class Story < ActiveRecord::Base	
	
	scope :is_published, where(:published => true)

	belongs_to :template
	has_many :sections, :order => 'position', dependent: :destroy
	has_and_belongs_to_many :users
	belongs_to :user
	validates :title, length: { maximum: 100 }
	validates :author, :presence => true, length: { maximum: 255 }
	validates :template, :presence => true
	validates :media_author, length: { maximum: 255 }
	attr_accessor :was_publishing

 	after_find :publishing_done?
	before_save :publish_date
	 

  	has_attached_file :thumbnail,
	  :url => "/system/places/thumbnail/:id/:style/:basename.:extension",
	  :styles => {:"250x250" => {:geometry => "250x250"}},
	  :default_url => "/assets/missing/250x250/missing.png" 

 before_post_process :transliterate_file_name

  validates_attachment :thumbnail,
    :content_type => { :content_type => ["image/jpeg", "image/png"] }
  	  	

  

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

	def transliterate_file_name
	  if thumbnail_file_name.present?
	    extension = File.extname(thumbnail_file_name).gsub(/^\.+/, '')
	    filename = thumbnail_file_name.gsub(/\.#{extension}$/, '')
	    self.thumbnail.instance_write(:file_name, "#{StoriesHelper.transliterate(filename)}.#{StoriesHelper.transliterate(extension)}")
	  end
	end
end
