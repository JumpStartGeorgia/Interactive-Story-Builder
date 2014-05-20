class Story < ActiveRecord::Base	
  # record public views
  is_impressionable :counter_cache => true 
	
	scope :is_published, where(:published => true)

	belongs_to :template
	has_many :sections, :order => 'position', dependent: :destroy
	has_and_belongs_to_many :users
	has_one :asset,     
	:conditions => "asset_type = #{Asset::TYPE[:story_thumbnail]}", 	 
	foreign_key: :item_id,
	dependent: :destroy

	belongs_to :user
	validates :title, :presence => true, length: { maximum: 100 }
	validates :author, :presence => true, length: { maximum: 255 }
	validates :template, :presence => true
	validates :media_author, length: { maximum: 255 }
	attr_accessor :was_publishing

 	after_find :publishing_done?
	before_save :publish_date
	before_save :generate_reviewer_key
	 
	accepts_nested_attributes_for :asset, :reject_if => lambda { |c| c[:asset].blank? }

	amoeba do
		enable
		exclude_field :asset
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


  # if the story is being published, record the date
	def publish_date		
	  if  self.was_publishing != self.published && self.published?
  	  	self.published_at = Time.now
  	  end     
  	end

	def asset_exists?
		self.asset.present? && self.asset.asset.exists?
	end  		

  # if the reviewer key does not exist, create it
  def generate_reviewer_key
    if self.reviewer_key.blank?
      self.reviewer_key = Random.new.rand(100_000_000..1_000_000_000-1)
    end
  end

	def transliterate_file_name
	  if thumbnail_file_name.present?
	    extension = File.extname(thumbnail_file_name).gsub(/^\.+/, '')
	    filename = thumbnail_file_name.gsub(/\.#{extension}$/, '')
	    self.thumbnail.instance_write(:file_name, "#{StoriesHelper.transliterate(filename)}.#{StoriesHelper.transliterate(extension)}")
	  end
	end
	
	def reset_fields_for_clone
	    self.published = false
	    self.published_at = nil
	    self.impressions_count = 0
	    self.reviewer_key = nil
	end

  def show_asset
    if self.asset.nil?
      Asset.new(:asset_type => Asset::TYPE[:story_thumbnail])
    else
      self.asset
    end
  end

  def ok?
	logger.debug("-------------------------------------------------------#{self.id}")
  end
end
