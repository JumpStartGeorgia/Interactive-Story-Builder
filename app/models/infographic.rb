class Infographic < ActiveRecord::Base
  include TranslationOverride

  translates :title, :caption, :description, :dataset_url

  belongs_to :section
  has_many :infographic_translations, :dependent => :destroy
  accepts_nested_attributes_for :infographic_translations


  #################################
  ## Validations
  validates :section_id, :presence => true

  #################################
  ## Callbacks

  before_destroy :trigger_translation_observer, prepend: true

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


end
