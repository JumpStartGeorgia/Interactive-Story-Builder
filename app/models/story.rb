class Story < ActiveRecord::Base	
	translates :shortened_url

  # for likes
  acts_as_votable
  
  # tagging system
  acts_as_taggable
  
  # fields to search for in a story
  scoped_search :on => [:title, :author, :media_author]
  scoped_search :in => :content, :on => [:caption, :sub_caption, :content]

  # record public views
  is_impressionable :counter_cache => true 
  # create permalink to story
  has_permalink :create_permalink, true

  has_many :story_translations, :dependent => :destroy
  has_many :invitations, :dependent => :destroy
	has_many :story_categories
	has_many :categories, :through => :story_categories, :dependent => :destroy
	belongs_to :user
  belongs_to :language, :primary_key => :locale, :foreign_key => :story_locale
	belongs_to :template
	has_many :sections, :order => 'position', dependent: :destroy
	has_and_belongs_to_many :users
	has_one :asset,     
	  :conditions => "asset_type = #{Asset::TYPE[:story_thumbnail]}", 	 
	  foreign_key: :item_id,
	  dependent: :destroy
	has_many :content, :through => :sections

	accepts_nested_attributes_for :asset, :reject_if => lambda { |c| c[:asset].blank? }

  attr_reader :tag_list_tokens
  attr_accessor :send_notification, :send_staff_pick_notification, :send_comment_notification
#  attr_accessible :name, :tag_list_tokens
  
	validates :title, :presence => true, length: { maximum: 100 }
	validates :author, :presence => true, length: { maximum: 255 }
	validates :permalink, :presence => true
#	validates :about, :presence => true
	validates :template_id, :presence => true
	validates :media_author, length: { maximum: 255 }
	validates :story_locale, :presence => true 

  # if the title changes, make sure the permalink is updated
#  before_save :check_title

  # if publishing, set the published date
	before_save :publish_date
	before_save :generate_reviewer_key
	before_save :shortened_url_generation
	 
#	after_save :update_filter_counts

  scope :recent, order("published_at desc, title asc")
  scope :reads, order("impressions_count desc, published_at desc, title asc")
  scope :likes, order("cached_votes_total desc, published_at desc, title asc")
  scope :comments, order("comments_count desc, published_at desc, title asc")
	scope :is_not_published, where(:published => false)
	scope :is_published, where(:published => true)
	scope :is_published_home_page, where(:published => true, :publish_home_page => true)
  scope :is_staff_pick, where(:staff_pick => true)  
  scope :stories_by_author, -> (user_id) {
    where(:user_id => user_id, :published => true).recent
  }

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
	  where(:story_locale => locale)
	end

	def self.by_category(id)
	  joins(:categories).where('categories.id = ?', id)
	end
	
	def self.by_authors(user_ids)
    where(:user_id => user_ids)
	end

  # get list of users that match the passed in query
  # - user must not be owner or already have invitation or is already collaborator
  # - search in user nickname and email
  def user_collaboration_search(q, limit=10)
    if q.present? and q.length > 1
      already_exists_ids = []
      already_exists_emails = []
      # add owner
      already_exists_ids << self.user_id
      # add colaborators
      if self.users.present?
        already_exists_ids << self.users.map{|x| x.id}
      end
      # add invitations
      pending = Invitation.pending_by_story(self.id)
      if pending.present?
        already_exists_emails << pending.map{|x| x.to_email}
      end
      
      already_exists_ids.flatten!
      already_exists_emails.flatten!
      
      sql = ""
      if already_exists_ids.present? && already_exists_emails.present?
        sql = "!(id in (:ids) or email in (:emails)) and "
      elsif already_exists_ids.present?
        sql = "!(id in (:ids)) and "
      elsif already_exists_emails.present?
        sql = "!(email in (:emails)) and "
      end
      sql << "(nickname like :search or email_no_domain like :search)"
      users = User.where([sql, 
          :ids => already_exists_ids.uniq,
          :emails => already_exists_emails.uniq,
          :search => "%#{q}%"])
          .limit(limit)          
      return users
    end  
  end


  # alias name for cached_votes_total
  def likes
    self.cached_votes_total
  end

  # if the story is being published, record the date
	def publish_date		
	  if self.published_changed? && self.published?
	  	self.published_at = Time.now
	  	# date is set so now permalink can be created
	  	self.generate_permalink!
	  end    
    return true 
	end

#  def check_title
#    self.generate_permalink! if self.title_changed?
#  end 
  
  def create_permalink
    if self.permalink_staging.present? && self.permalink_staging != self.permalink
      self.permalink_staging.dup
    else
      self.title.dup
    end
  end

  # if the story is published and the counts are not being updated
  # update the filter counts
  def update_filter_counts
    if (self.published_changed? || self.published?) && 
        !self.cached_votes_total_changed? && !self.impressions_count_changed? && 
        !self.comments_count_changed? && !self.staff_pick_changed?
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
    return true
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
  
  # when a comment occurs, update the count by 1
  def increment_comment_count
    self.comments_count += 1
    self.save
  end
  
  # remove quotes from tags
  def tag_list_tokens=(tokens)
    self.tag_list = tokens.gsub("'", "")
  end  
  
  
  # if the story was published or permalink changed and was published
  # create a new shortened url 
  def shortened_url_generation
	  if (self.published_changed? && self.published?) || (self.permalink_changed? && self.published?)
      generate_shortened_url
	  end 
    shortened_url_generation    
    return true
  end
  
  # generate bit.ly shortened url
  def generate_shortened_url
    require 'open-uri'
    require 'uri'
    token = Rails.env.production? ? ENV['STORY_BUILDER_BITLY_TOKEN'] : ENV['STORY_BUILDER_BITLY_TOKEN_DEV']
    # only continue if the token is in the environment variables
    if token.present?
      I18n.available_locales.each do |locale|
        puts "- locale = #{locale}"
        long_url = URI.encode(UrlHelpers.storyteller_show_url(:id => self.permalink, :locale => locale))
        url = "https://api-ssl.bitly.com/v3/shorten?access_token=#{token}&longUrl=#{long_url}"
        puts "- url = #{url}"
        begin
          results = open(url)
          if results.present?
            json = JSON.parse(results.read)
            puts "- json = #{json}"
            trans = self.story_translations.select{|x| x.locale == locale.to_s}
            if trans.blank?
              trans = self.story_translations.build(:locale => locale)
            end
            # if all went well, save the url
            if json.present? && json['status_code'] == 200 && json['data']['url'].present?
              puts "--> saving url"
              trans.shortened_url = json['data']['url']
            end
          end      
        rescue
        end    
      end
    end
  end
  
  
end
