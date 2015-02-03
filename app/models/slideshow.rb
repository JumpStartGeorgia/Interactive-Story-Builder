class Slideshow < ActiveRecord::Base
  include TranslationOverride

  translates :title, :caption

	belongs_to :section	  	
	# has_many :assets,     
	#   :conditions => "asset_type = #{Asset::TYPE[:slideshow_image]}",    
	#   foreign_key: :item_id,
	#   dependent: :destroy,
	#   :order => 'position'

 #  accepts_nested_attributes_for :assets, :reject_if => lambda { |c| c[:asset].blank? && c[:asset_exists] != 'true' }, :allow_destroy => true

  has_many :slideshow_translations, :dependent => :destroy
  accepts_nested_attributes_for :slideshow_translations

  #################################
  ## Validations
	validates :section_id, :presence => true  

  #################################
  # settings to clone story
  amoeba do
    enable
    clone [:slideshow_translations]
  end


  ##############################
  ## shortcut methods to get to asset objects in translation
  ##############################
  # create model variable @asset to store the asset record for later use without having to call the db again
  @assets = nil

  def assets
    if @assets.present?
      return @assets
    else
      x = with_translation(self.current_locale, false)
      if x.present?
        @assets = x.assets
        return @assets
      end
    end
  end

  #################################

  # get the translation record for the given locale
  # if it does not exist, build a new one if wanted
  def with_translation(locale, build_if_missing=true)
    @local_translations ||= {}
    if @local_translations[locale].blank?
      x = self.slideshow_translations.where(:locale => locale).first
      if x.blank? && build_if_missing
        x = self.slideshow_translations.build(locale: locale)
      end

      @local_translations[locale] = x
    end
    return @local_translations[locale]
  end


  ##############################
end
