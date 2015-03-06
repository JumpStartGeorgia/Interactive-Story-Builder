class Infographic < ActiveRecord::Base
  include TranslationOverride

  translates :title, :caption, :description, :dataset_url, :dynamic_url, :dynamic_code

  belongs_to :section
  has_many :infographic_translations, :dependent => :destroy
  accepts_nested_attributes_for :infographic_translations

  TYPE = {static: 1, dynamic: 2}
  DYNAMIC_RENDER = {inline: 1, popup: 2}

  #################################
  ## Validations
  validates :section_id, :presence => true
  validates :subtype, :presence => true, :inclusion => { :in => TYPE.values }  
  validates :dynamic_width, numericality: { greater_than_or_equal_to: 200, allow_nil: true }, if: :dynamic_type? 
  validates :dynamic_height, numericality: { greater_than_or_equal_to: 200, allow_nil: true },  if: :dynamic_type?


  #################################
  ## Callbacks

  before_destroy :trigger_translation_observer, prepend: true
  before_validation :trigger_translation_validation, prepend: true

  # need this so if loop or info flags change the code will be updated in translation
  def trigger_translation_validation
    if self.dynamic_width_changed? || self.dynamic_height_changed?
      self.infographic_translations.each do |trans|
        trans.dynamic_code_will_change!
      end
    end
  end
  def trigger_translation_observer
    self.infographic_translations.each do |trans|
      trans.is_progress_increment = false
    end
  end

  #################################
  # settings to clone story
  amoeba do
    enable
    clone [:infographic_translations]
  end





  ##############################
  ## shortcut methods to get to asset objects in translation
  ##############################
  # create model variable @asset to store the asset record for later use without having to call the db again
  @image = nil
  @dataset_file = nil
  @datasources = nil

  def datasources
    if @datasources.present?
      return @datasources
    else
      x = with_translation(self.current_locale, false)
      if x.present?
        @datasources = x.infographic_datasources
        return @datasources
      end
    end
  end

  def image
    if @image.present?
      return @image
    else
      x = with_translation(self.current_locale, false)
      if x.present?
        @image = x.image
        return @image
      end
    end
  end

  def image_exists?
    image.present? && image.file.exists?
  end     

  def dataset_file
    if @dataset_file.present?
      return @dataset_file
    else
      x = with_translation(self.current_locale, false)
      if x.present?
        @dataset_file = x.dataset_file
        return @dataset_file
      end
    end
  end

  def dataset_file_exists?
    dataset_file.present? && dataset_file.file.exists?
  end     

#################################

  # get the translation record for the given locale
  # if it does not exist, build a new one if wanted
  def with_translation(locale, build_if_missing=true)
    @local_translations ||= {}
    if @local_translations[locale].blank?
      x = self.infographic_translations.where(:locale => locale).first
      if x.blank? && build_if_missing
        x = self.infographic_translations.build(locale: locale)
      end

      @local_translations[locale] = x
    end
    return @local_translations[locale]
  end

#################################

  # create the alt text for the infographic image
  def alt_text
    alt = ''

    if self.caption.present?
      alt << self.caption
      alt << ' - '
    end

    if self.description.present?
      alt << self.description
    end

    return alt
  end

  def static_type?    
    self.subtype == TYPE[:static]
  end
  def dynamic_type?    
    self.subtype == TYPE[:dynamic]
  end

  def inline_render?
    self.dynamic_render == DYNAMIC_RENDER[:inline]
  end
  def popup_render?
    self.dynamic_render == DYNAMIC_RENDER[:popup]
  end
end
