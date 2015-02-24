class Slideshow < ActiveRecord::Base
  include TranslationOverride

  translates :title, :caption, :description

	belongs_to :section	  	
	# has_many :asset_files,     
	#   :conditions => "asset_type = #{Asset::TYPE[:slideshow_image]}",    
	#   foreign_key: :item_id,
	#   dependent: :destroy,
	#   :order => 'position'

 #  accepts_nested_attributes_for :asset_files, :reject_if => lambda { |c| c[:asset].blank? && c[:asset_exists] != 'true' }, :allow_destroy => true

  has_many :slideshow_translations, :dependent => :destroy
  accepts_nested_attributes_for :slideshow_translations

  #################################
  ## Validations
	validates :section_id, :presence => true  

  # #################################
  # ## Callbacks
  before_destroy :trigger_translation_observer, prepend: true

  # need this so if loop or info flags change the code will be updated in translation
  # def trigger_translation_validation
  #   if self.dynamic_width_changed? || self.dynamic_height_changed?
  #     self.infographic_translations.each do |trans|
  #       trans.dynamic_code_will_change!
  #     end
  #   end
  # end
  def trigger_translation_observer
    self.slideshow_translations.each do |trans|
      trans.is_progress_increment = false
    end
  end


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
  @asset_files = nil

  def asset_files
    if @asset_files.present?
      return @asset_files
    else
      x = with_translation(self.current_locale, false)
      if x.present?
        @asset_files = x.asset_files
        return @asset_files
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
