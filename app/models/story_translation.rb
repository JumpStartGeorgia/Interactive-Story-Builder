class StoryTranslation < ActiveRecord::Base

  extend FriendlyId
  friendly_id :friendly_slug_generator, use: [:slugged, :history, :scoped], slug_column: :permalink, :scope => :locale

  belongs_to :story
  belongs_to :language, :primary_key => :locale, :foreign_key => :locale

  has_one :asset,
    :conditions => "asset_type = #{Asset::TYPE[:story_thumbnail]}",
    foreign_key: :item_id,
    dependent: :destroy

  #has_permalink :create_permalink, true

  accepts_nested_attributes_for :asset, :reject_if => lambda { |c| c[:asset].blank? && c[:asset_clone_id].blank? }

  attr_accessible :story_id, :locale, :shortened_url, :title, :permalink, :permalink_staging, :author, :media_author, :about,
      :published, :published_at, :language_type, :translation_percent_complete, :translation_author, :asset_attributes

  attr_accessor :is_progress_increment, :progress_story_id

  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 100 }
#  validates :author, :presence => true, length: { maximum: 255 }
  validates :permalink, :presence => true
  validates_uniqueness_of :permalink, conditions: -> { where.not(story_id: self.story_id) }
  validates :media_author, length: { maximum: 255 }
  validates :translation_author, length: { maximum: 255 }
  #validates_uniqueness_of :story_id, scope: [:locale]


#  validates :shortened_url, :presence => true

  # def required_data_provided?
  #   provided = false

  #   provided = self.shortened_url.present?

  #   return provided
  # end

  # def add_required_data(obj)
  #   self.shortened_url = obj.shortened_url if self.shortened_url.blank?
  # end

  def should_generate_new_friendly_id?
    (permalink_staging_changed? && permalink_staging.present?) || (new_record? && title.present?)
  end

  def friendly_slug_generator
    friendly_slug_normalizer(permalink_staging.present? ? permalink_staging : title)
  end
  def friendly_slug_normalizer(str)
    unless str.blank?
      n = str.mb_chars.downcase.to_s.strip.latinize.to_ascii
      n.gsub!(/\s+/,            '-')
      n.gsub!(/[^[:alnum:]_\-]/, '')
      n.gsub!(/-{2,}/,          '-')
      n.gsub!(/^-/,             '')
      n.gsub!(/-$/,             '')
      n
    end
  end
  # def create_permalink
  #   if self.permalink_staging.present? && self.permalink_staging != self.permalink
  #     self.permalink_staging.dup
  #   else
  #     self.title.dup
  #   end
  # end

  #################################
  ## Callbacks
  before_save :publish_date
  before_save :shortened_url_generation
#  after_save :update_filter_counts

  # if the story is being published, record the date
  def publish_date
    logger.debug "%%%%%%%%%%%%% pub date, changed? #{self.published_changed?}; published? #{self.published?}; date blank #{self.published_at.blank?}"
    if self.published_changed? && self.published? && self.published_at.blank?
      logger.debug "%%%%% setting date"
      self.published_at = Time.now
    elsif !self.published?
      logger.debug "%%%%% nilling date"
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

  # # if the story published flag changes
  # # update the filter counts
  # def update_filter_counts
  #   if self.published_changed?

  #     Category.update_published_stories_flags
  #     Language.update_published_stories_flags
  #   end
  # end

  #################################
  # settings to clone story
  amoeba do
    enable

    # update the title
    customize(lambda { |original_post,new_post|
      if original_post.title.length > 92
        new_post.title = original_post.title[0..91]
      end
      new_post.title += " (Clone)"
    })
    # reset some fields
    nullify :published
    nullify :published_at
    nullify :permalink
    nullify :permalink_staging
    nullify :shortened_url

  end

  # generate bit.ly shortened url
  def generate_shortened_url
    require 'open-uri'
    require 'uri'
    token = Rails.env.production? ? ENV['STORY_BUILDER_BITLY_TOKEN'] : ENV['STORY_BUILDER_BITLY_TOKEN_DEV']
    # only continue if the token is in the environment variables
    if token.present?
      # if the story locale is not one of the app locales, use the default locale
      locale = self.locale
      locale = I18n.default_locale if !I18n.available_locales.include?(self.locale.to_sym)
      puts "- locale = #{locale}"

      long_url = URI.encode(UrlHelpers.storyteller_show_url(:id => self.permalink, :locale => locale))
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
