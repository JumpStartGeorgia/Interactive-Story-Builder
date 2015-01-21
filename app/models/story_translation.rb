class StoryTranslation < ActiveRecord::Base
	belongs_to :story
  belongs_to :language, :primary_key => :locale, :foreign_key => :locale

  has_permalink :create_permalink, true

  attr_accessible :story_id, :locale, :shortened_url, :title, :permalink, :permalink_staging, :author, :media_author, :about, 
      :published, :published_at, :language_type, :translation_percent_complete, :translation_author

  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 100 }
  validates :author, :presence => true, length: { maximum: 255 }
  validates :permalink, :presence => true
  validates :media_author, length: { maximum: 255 }
  #validates :shortened_url, :presence => true

  # def required_data_provided?
  #   provided = false
    
  #   provided = self.shortened_url.present?
    
  #   return provided
  # end
  
  # def add_required_data(obj)
  #   self.shortened_url = obj.shortened_url if self.shortened_url.blank?
  # end

  def create_permalink
    if self.permalink_staging.present? && self.permalink_staging != self.permalink
      self.permalink_staging.dup
    else
      self.title.dup
    end
  end

  #################################
  ## Callbacks
  before_save :publish_date
  before_save :shortened_url_generation
  after_save :update_filter_counts

  # if the story is being published, record the date
  def publish_date    
    if self.published_changed? && self.published?
      self.published_at = Time.now
    elsif !self.published?
      self.published_at = nil
    end    
    return true 
  end

  # if the story was published or permalink changed and was published
  # create a new shortened url 
  def shortened_url_generation
    if (self.published_changed? && self.published?) || (self.permalink_changed? && self.published?)
      generate_shortened_url
    end     
    return true
  end
  
  # if the story published flag changes
  # update the filter counts
  def update_filter_counts
    if self.published_changed?

      Category.update_published_stories_flags
      Language.update_published_stories_flags
    end
  end

  #################################
  # settings to clone story
  amoeba do
    enable

    # update the title
    append :title => " (Clone)"

    # reset some fields
    nullify :published
    nullify :published_at
    nullify :permalink
    nullify :permalink_staging

  end

private

  # generate bit.ly shortened url
  def generate_shortened_url
    require 'open-uri'
    require 'uri'
    token = Rails.env.production? ? ENV['STORY_BUILDER_BITLY_TOKEN'] : ENV['STORY_BUILDER_BITLY_TOKEN_DEV']
    # only continue if the token is in the environment variables
    if token.present?
      puts "- locale = #{self.locale}"
      long_url = URI.encode(UrlHelpers.storyteller_show_url(:id => self.permalink, :locale => self.locale))
      url = "https://api-ssl.bitly.com/v3/shorten?access_token=#{token}&longUrl=#{long_url}"
      puts "- url = #{url}"
      begin
        results = open(url)
        if results.present?
          json = JSON.parse(results.read)
          puts "- json = #{json}"
          self.shortened_url = json['data']['url']
        end      
      rescue
      end    
    end
  end

end
