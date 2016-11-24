class EmbedMedium < ActiveRecord::Base
  include TranslationOverride

  translates :title, :url, :code

  belongs_to :section

  has_many :embed_medium_translations, :dependent => :destroy
  accepts_nested_attributes_for :embed_medium_translations
  attr_accessible :section_id, :dimension, :embed_medium_translations_attributes

  DIMENSION_TYPE = { preserve: 0, fullscreen: 1, fit: 2 }

  #################################
  ## Validations
	validates :section_id, :presence => true

  # #################################
  # ## Callbacks

  before_destroy :trigger_translation_observer, prepend: true
  def trigger_translation_observer
    self.embed_medium_translations.each do |trans|
      trans.is_progress_increment = false
    end
  end

  #################################
  # settings to clone story
  amoeba do
    enable
    clone [:embed_medium_translations]
  end

  #################################

  # get the translation record for the given locale
  # if it does not exist, build a new one if wanted
  def with_translation(locale, build_if_missing=true)
    @local_translations ||= {}
    if @local_translations[locale].blank?
      x = self.embed_medium_translations.where(:locale => locale).first
      if x.blank? && build_if_missing
        x = self.embed_medium_translations.build(locale: locale)
      end

      @local_translations[locale] = x
    end
    return @local_translations[locale]
  end
  def get_dimension_class
    "dimension-#{DIMENSION_TYPE.index(self.dimension).to_s}"
  end

end
