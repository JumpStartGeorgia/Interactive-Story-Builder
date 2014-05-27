class Story < ActiveRecord::Base	
	require 'utf8_converter'

  # record public views
  is_impressionable :counter_cache => true 
  # create permalink to story
  has_permalink :create_permalink
	
	scope :is_published, where(:published => true)
	scope :is_published_home_page, where(:published => true, :publish_home_page => true)
  scope :is_staff_pick, where(:staff_pick => true)
  
	belongs_to :user
  belongs_to :language, :primary_key => :locale, :foreign_key => :locale
	belongs_to :template
	has_many :sections, :order => 'position', dependent: :destroy
	has_and_belongs_to_many :users
	has_one :asset,     
	  :conditions => "asset_type = #{Asset::TYPE[:story_thumbnail]}", 	 
	  foreign_key: :item_id,
	  dependent: :destroy

	accepts_nested_attributes_for :asset, :reject_if => lambda { |c| c[:asset].blank? }

	validates :title, :presence => true, length: { maximum: 100 }
	validates :author, :presence => true, length: { maximum: 255 }
	validates :about, :presence => true
	validates :template, :presence => true
	validates :media_author, length: { maximum: 255 }
	validates :language, :presence => true
	attr_accessor :was_publishing, :title_was

  # if the title changes, make sure the permalink is updated
 	after_find :set_title
  before_save :check_title

 	after_find :record_initial_values
	before_save :publish_date
	before_save :generate_reviewer_key
	 

  DEMO_ID = 2

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
		includes(sections: [:media,:content,:embed_medium])
		.where(stories: {id: story_id})
		.first
	end
	
	def self.demo
	  fullsection(DEMO_ID)
	end


	def record_initial_values
		self.was_publishing = self.has_attribute?(:published) ? self.published : nil		
	end


  # if the story is being published, record the date
	def publish_date		
	  if self.was_publishing != self.published && self.published?
	  	self.published_at = Time.now
	  	# date is set so now permalink can be created
	  	self.permalink = create_permalink
	  end     
	end

  def set_title
		self.title_was = self.has_attribute?(:title) ? self.title : nil		
  end
  
  def check_title
    self.generate_permalink! if self.title != self.title_was
  end 
  
  def create_permalink
    if self.published_at.present? && self.published?
      date = ''
      date << self.published_at.to_date.to_s
      date << '-'
      "#{date}#{Utf8Converter.convert_ka_to_en(self.title.clone.to_ascii.gsub(/[^0-9A-Za-z|_\- ]/,''))}"
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
	    self.permalink = nil
	end

  def show_asset
    if self.asset.nil?
      Asset.new(:asset_type => Asset::TYPE[:story_thumbnail])
    else
      self.asset
    end
  end
end
