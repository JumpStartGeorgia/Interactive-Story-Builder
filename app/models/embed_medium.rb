class EmbedMedium < ActiveRecord::Base
  include TranslationOverride

  translates :title, :url, :code

  belongs_to :section

  has_many :embed_medium_translations, :dependent => :destroy
  accepts_nested_attributes_for :embed_medium_translations


  #################################
  ## Validations
	validates :section_id, :presence => true

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
  

end
