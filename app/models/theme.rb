class Theme < ActiveRecord::Base
  translates :name, :edition, :description, :permalink

  has_many :theme_features, :dependent => :destroy, :order => 'position'
  has_many :featured_stories, :through => :theme_features, :order => 'position'
  has_many :story_themes, :dependent => :destroy
  has_many :stories, :through => :story_themes
  has_many :theme_translations, :dependent => :destroy
  accepts_nested_attributes_for :theme_translations
  accepts_nested_attributes_for :theme_features, :reject_if => lambda { |c| c[:story_id].blank?}, allow_destroy: true

  attr_accessible :id, :is_published, :published_at, :show_home_page, :theme_translations_attributes, :theme_features_attributes
  attr_accessor :send_notification


  scope :published, where(:is_published => 1)


  #################################
  ## Callbacks
  after_save :reset_show_home_page_flag
  before_validation :check_if_can_publish

  # only one theme can be marked as being on the home page
  # if this record was marked as being on the home page, reset all other themes to not be on home page
  def reset_show_home_page_flag
    if self.is_published? && self.show_home_page? && self.show_home_page_changed?
      Theme.where('id != ?', self.id).update_all(:show_home_page => false)
    end
    return true
  end

  # if trying to publish the story, make sure it can be published
  # must have published items
  def check_if_can_publish
    if self.is_published_changed? && self.is_published? && self.published_item_count == 0
      self.errors.add(:base, I18n.t('activerecord.errors.messages.publish_theme'))
    end    
    return true 
  end

  #################################

  def self.sorted
    with_translations(I18n.locale).order('themes.published_at desc, theme_translations.name')
  end

  def self.for_homepage
    with_translations(I18n.locale).where(:is_published => true, :show_home_page => true).first
  end


  #################################
  # name (edition)
  def formatted_name
    "#{self.name} (#{self.edition})"
  end

  # get the number of published items in this theme
  def published_item_count
    Theme.select('distinct stories.id').joins(:stories => :story_translations).where('story_translations.published = 1 and themes.id = ?', self.id).count
  end  
end
