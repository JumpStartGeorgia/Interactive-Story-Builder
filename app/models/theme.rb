class Theme < ActiveRecord::Base
  translates :name, :edition, :description, :permalink

  has_many :theme_translations, :dependent => :destroy
  accepts_nested_attributes_for :theme_translations
  attr_accessible :is_published, :published_at, :show_home_page, :theme_translations_attributes


  scope :published, where(:is_published => 1)


  #################################
  ## Callbacks
  after_save :reset_show_home_page_flag

  # only one theme can be marked as being on the home page
  # if this record was marked as being on the home page, reset all other themes to not be on home page
  def reset_show_home_page_flag
    if self.is_published? && self.show_home_page? && self.show_home_page_changed?
      Theme.where('id != ?', self.id).update_all(:show_home_page => false)
    end
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
end
