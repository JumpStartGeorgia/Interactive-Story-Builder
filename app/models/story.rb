class Story < ActiveRecord::Base	
  # fields to search for in a story
  scoped_search :on => [:title, :author, :media_author]
  scoped_search :in => :content, :on => [:caption, :sub_caption, :content]

  # record public views
  is_impressionable :counter_cache => true 
  # create permalink to story
  has_permalink :create_permalink, true
	
	scope :is_published, where(:published => true)
	scope :is_published_home_page, where(:published => true, :publish_home_page => true)
  scope :is_staff_pick, where(:staff_pick => true)
  
	has_many :story_categories
	has_many :categories, :through => :story_categories, :dependent => :destroy
	belongs_to :user
  belongs_to :language, :primary_key => :locale, :foreign_key => :locale
	belongs_to :template
	has_many :sections, :order => 'position', dependent: :destroy
	has_and_belongs_to_many :users
	has_one :asset,     
	  :conditions => "asset_type = #{Asset::TYPE[:story_thumbnail]}", 	 
	  foreign_key: :item_id,
	  dependent: :destroy
	has_many :content, :through => :sections

	accepts_nested_attributes_for :asset, :reject_if => lambda { |c| c[:asset].blank? }

	validates :title, :presence => true, length: { maximum: 100 }
	validates :author, :presence => true, length: { maximum: 255 }
#	validates :about, :presence => true
	validates :template_id, :presence => true
	validates :media_author, length: { maximum: 255 }
	validates :locale, :presence => true

  # if the title changes, make sure the permalink is updated
  before_save :check_title

  # if publishing, set the published date
	before_save :publish_date
	before_save :generate_reviewer_key
	 
	after_save :update_counts

  scope :recent, order("published_at desc")
  scope :reads, order("impressions_count desc")


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
	
	def self.by_language(locale)
	  where(:locale => locale)
	end

	def self.by_category(id)
	  joins(:categories).where('categories.id = ?', id)
	end


  # if the story is being published, record the date
	def publish_date		
	  if self.published_changed? && self.published?
	  	self.published_at = Time.now
	  	# date is set so now permalink can be created
	  	self.generate_permalink!
	  end     
	end

  def check_title
    self.generate_permalink! if self.title_changed?
  end 
  
  def create_permalink
    if self.published_at.present? && self.published?
      date = ''
      date << self.published_at.to_date.to_s
      date << '-'
      "#{date}#{self.title.dup}"
    end
  end

  # if the story was published/unpublished 
  # - or if the languages changed, update the lang count
  # - or if categories changed, update category count
  def update_counts
    if self.published?
      Category.update_counts
      Language.update_counts
    end
=begin
    # languages
    if self.published_changed?
      if self.locale_changed?
        if self.published?
          Language.increment_count(locale)
        else
          Language.decrement_count(locale_was)
        end
      elsif self.published?
        Language.increment_count(locale)
      else
        Language.decrement_count(locale)
      end
    elsif self.locale_changed? && self.published?
      Language.decrement_count(locale_was)
      Language.increment_count(locale)
    end
=end    
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
