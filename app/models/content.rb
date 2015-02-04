class Content < ActiveRecord::Base
  include TranslationOverride

  translates :title, :caption, :sub_caption, :text

	belongs_to :section	 

  has_many :content_translations, :dependent => :destroy
  accepts_nested_attributes_for :content_translations

  #################################
  # settings to clone story
  amoeba do
    enable
    clone [:content_translations]
  end


  #################################

  # get the translation record for the given locale
  # if it does not exist, build a new one if wanted
  def with_translation(locale, build_if_missing=true)
    @local_translations ||= {}
    if @local_translations[locale].blank?
      x = self.content_translations.where(:locale => locale).first
      if x.blank? && build_if_missing
        x = self.content_translations.build(locale: locale)
      end

      @local_translations[locale] = x
    end
    return @local_translations[locale]
  end

  #################################
	def to_json(options={})
     options[:except] ||= [:created_at, :updated_at]
     super(options)
   end
end
