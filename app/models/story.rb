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
	 
	after_save :update_filter_counts

  scope :recent, order("stories.published_at desc, stories.title asc")
  scope :reads, order("stories.impressions_count desc, stories.published_at desc, stories.title asc")
  scope :likes, order("stories.cached_votes_total desc, stories.published_at desc, stories.title asc")
  scope :comments, order("stories.comments_count desc, stories.published_at desc, stories.title asc")
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

    # update the title
    append :title => " (Clone)"

    # reset some fields
    nullify :published
    nullify :published_at
    nullify :reviewer_key
    nullify :permalink
    nullify :permalink_staging
    nullify :staff_pick
    # nullify :impressions_count
    # nullify :cached_votes_total
    # nullify :cached_votes_score
    # nullify :cached_votes_up
    # nullify :cached_votes_down
    # nullify :cached_weighted_score
    # nullify :comments_count

    # reset counters to 0
    # for some reason nullify is not working for these
    customize(lambda { |original_asset,new_asset|
      new_asset.impressions_count = 0
      new_asset.comments_count = 0
      new_asset.cached_votes_total = 0
      new_asset.cached_votes_score = 0
      new_asset.cached_votes_up = 0
      new_asset.cached_votes_down = 0
      new_asset.cached_weighted_score = 0
    })

    # do not copy impression views
    exclude_field :impressions

    # do not copy votes
    exclude_field :votes_for

    # tags cannot be cloned - think this is because the story_id is saved under taggable_id
    exclude_field :tag_taggings

    # do not copy invitation
    exclude_field :invitations

    # shortened url created when published
    exclude_field :story_translations

    # clone the associations
		clone [:sections, :categories]
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
	
	# get all of the unique story locales for published stories
	def self.published_locales
	  select('story_locale').is_published_home_page.map{|x| x.story_locale}.uniq.sort
	end

	# get all of the unique story locales for published stories
	def self.published_categories
    select('story_categories.category_id').is_published_home_page.joins(:story_categories).map{|x| x['category_id']}.uniq.sort
	end

  def self.include_categories
    includes(:categories)
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
  	elsif !self.published?
	  	self.published_at = nil
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

      Category.update_published_stories_flags
      Language.update_published_stories_flags
#      Category.update_counts
#      Language.update_counts
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
	
  # use amoeba to clone the story and all of its records
  # after the clone is complete, copy all assets from the original story to the new story
  def clone_story
    clone = self.amoeba_dup
    if clone.save
      puts "$$$$$$$$$ clone successful - copying asset files"

      # copy the assets
      # - have to copy each one by hand so can update the file name with the id of the new asset
      original_id = self.id
      new_id = clone.id

      # story thumbnail
      puts "$$$$$$$$$ clone successful - copying thumbnail"
      if self.asset.present? && self.asset.asset.exists? 
        Dir.glob(self.asset.asset.path.gsub('/original/', '/*/')).each do |file|       
          copy_asset file, file.gsub("/thumbnail/#{original_id}/", "/thumbnail/#{new_id}/") 
        end
      end

      # section audio
      puts "$$$$$$$$$ clone successful - copying audio"
      new_audio = clone.sections.select{|x| x.asset.present? && x.asset.asset.exists?}.map{|x| x.asset}
      self.sections.select{|x| x.asset.present? && x.asset.asset.exists?}.map{|x| x.asset}.each do |audio|
        # find matching record
        record = new_audio.select{|x| x.asset_file_name == audio.asset_file_name && 
                                      x.asset_content_type == audio.asset_content_type && 
                                      x.asset_file_size == audio.asset_file_size && 
                                      x.asset_updated_at == audio.asset_updated_at}.first
        # copy the file if match found
        if record.present?
          copy_asset audio.asset.path, audio.asset.path.gsub("/audio/#{original_id}/", "/audio/#{new_id}/")
                                                        .gsub("/#{audio.id}__", "/#{record.id}__") 
        end
      end

      # slideshow
      puts "$$$$$$$$$ clone successful - copying slideshow"
      new_ss = clone.sections.select{|x| x.slideshow?}.map{|x| x.slideshow.assets}.flatten.select{|x| x.asset.exists?}
      self.sections.select{|x| x.slideshow?}.map{|x| x.slideshow.assets}.flatten.select{|x| x.asset.exists?}.each do |img|
        # find matching record
        record = new_ss.select{|x| x.asset_file_name == img.asset_file_name && 
                                      x.asset_content_type == img.asset_content_type && 
                                      x.asset_file_size == img.asset_file_size && 
                                      x.asset_updated_at == img.asset_updated_at}.first
        # copy the file if match found
        if record.present?
          Dir.glob(img.asset.path.gsub('/original/', '/*/')).each do |file|       
            copy_asset file, file.gsub("/slideshow/#{original_id}/", "/slideshow/#{new_id}/") 
                                  .gsub("/#{img.id}__", "/#{record.id}__") 
          end
        end
      end


      # images
      puts "$$$$$$$$$ clone successful - copying images"
      new_img = clone.sections.select{|x| x.media?}.map{|x| x.media}.flatten.select{|x| x.image_exists?}.map{|x| x.image}
      self.sections.select{|x| x.media?}.map{|x| x.media}.flatten.select{|x| x.image_exists?}.map{|x| x.image}.each do |img|
        # find matching record
        record = new_img.select{|x| x.asset_file_name == img.asset_file_name && 
                                      x.asset_content_type == img.asset_content_type && 
                                      x.asset_file_size == img.asset_file_size && 
                                      x.asset_updated_at == img.asset_updated_at}.first
        # copy the file if match found
        if record.present?
          Dir.glob(img.asset.path.gsub('/original/', '/*/')).each do |file|       
            copy_asset file, file.gsub("/images/#{original_id}/", "/images/#{new_id}/") 
                                  .gsub("/#{img.id}__", "/#{record.id}__") 
          end
        end
      end

      # videos
      puts "$$$$$$$$$ clone successful - copying videos"
      new_video = clone.sections.select{|x| x.media?}.map{|x| x.media}.flatten.select{|x| x.video_exists?}.map{|x| x.video}
      self.sections.select{|x| x.media?}.map{|x| x.media}.flatten.select{|x| x.video_exists?}.map{|x| x.video}.each do |video|
        # find matching record
        record = new_video.select{|x| x.asset_file_name == video.asset_file_name && 
                                      x.asset_content_type == video.asset_content_type && 
                                      x.asset_file_size == video.asset_file_size && 
                                      x.asset_updated_at == video.asset_updated_at}.first
        # copy the file if match found
        if record.present?
          # it is possible that the original video is not mp4 so need to look for anything that has same basename (ignore file ext)
          ext = File.extname(video.asset.path)
          basename = File.basename(video.asset.path)
          name = File.basename(video.asset.path, ext)

          Dir.glob(video.asset.path.gsub('/original/', '/*/').gsub(basename, "#{name}.*")).each do |file|       
            copy_asset file, file.gsub("/video/#{original_id}/", "/video/#{new_id}/") 
                                  .gsub("/#{video.id}__", "/#{record.id}__") 
          end

          # get the poster folder too
          copy_asset video.asset.path(:poster), video.asset.path(:poster).gsub("/video/#{original_id}/", "/video/#{new_id}/") 
                                .gsub("/#{video.id}__", "/#{record.id}__") 

        end
      end

      # # look in each directory in path and see if it has folder for original_id
      # # if so, copy it for new story
      # Dir.glob("#{path}/*").select {|f| File.directory? f}.each do |directory|
      #   if Dir.exists?("#{directory}/#{original_id}")
      #     puts "$$$$$$$$$ - copying files from #{directory}"
      #     FileUtils.cp_r "#{directory}/#{original_id}", "#{directory}/#{new_id}"
      #   end
      # end
    end

    return clone
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
  
  

  private 

  def copy_asset(original_path, new_path)
    # make sure new path directory structure exists
    FileUtils.mkdir_p(File.dirname(new_path))
    FileUtils.cp original_path, new_path
  end  
end
