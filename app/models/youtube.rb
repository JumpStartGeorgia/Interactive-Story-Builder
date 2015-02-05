class Youtube < ActiveRecord::Base
  include TranslationOverride

	translates :title, :url, :menu_lang, :cc, :cc_lang, :code

	belongs_to :section
	has_many :youtube_translations, :dependent => :destroy

	accepts_nested_attributes_for :youtube_translations
	attr_accessible :section_id, :fullscreen, :loop, :info, :youtube_translations_attributes
 	alias_attribute  :trans, :youtube_translations

  #################################
  ## Validations
	validates :section_id, :presence => true

  # #################################
  # ## Callbacks

  before_destroy :trigger_translation_observer, prepend: true
  def trigger_translation_observer
    self.youtube_translations.each do |trans|
      trans.is_progress_increment = false
    end
  end

  #################################
  # settings to clone story
  amoeba do
    enable
    clone [:youtube_translations]
  end

  #################################

  # get the translation record for the given locale
  # if it does not exist, build a new one if wanted
  def with_translation(locale, build_if_missing=true)
    @local_translations ||= {}
    if @local_translations[locale].blank?
      x = self.youtube_translations.where(:locale => locale).first
      if x.blank? && build_if_missing
        x = self.youtube_translations.build(locale: locale)
      end

      @local_translations[locale] = x
    end
    return @local_translations[locale]
  end

end
