class Medium < ActiveRecord::Base
  include TranslationOverride

  translates :title, :caption, :caption_align, :source, :infobox_type

#  acts_as_list scope: :section

	belongs_to :section	
    
  # has_one :image,     
  #   :conditions => "asset_type = #{Asset::TYPE[:media_image]}",    
  #   foreign_key: :item_id,
  #   class_name: "Asset",
  #   dependent: :destroy

  # has_one :video,     
  #   :conditions => "asset_type = #{Asset::TYPE[:media_video]}",    
  #   foreign_key: :item_id,
  #   class_name: "Asset",
  #   dependent: :destroy

  # accepts_nested_attributes_for :image, :reject_if => lambda { |c| c[:asset].blank? }
  # accepts_nested_attributes_for :video, :reject_if => lambda { |c| c[:asset].blank? }

  has_many :medium_translations, :dependent => :destroy
  accepts_nested_attributes_for :medium_translations

  # attr_accessor :video_date_changed, :is_amoeba


	TYPE = {image: 1, video: 2}
  INFOBOX_TYPE = {floating: 0, fixed: 1}

  #################################
  ## Validations
  validates :section_id, :presence => true
  validates :media_type, :presence => true, :inclusion => { :in => TYPE.values }  

  # validates :image, presence: true, if: :image_type?
  # validates :video, presence: true, if: :video_type?

  # #################################
  # ## Callbacks

  before_destroy :trigger_translation_observer, prepend: true
  def trigger_translation_observer
    logger.debug "============== medium before destroy"
    self.medium_translations.each do |trans|
      trans.is_progress_increment = false
    end
  end


  #################################
  # settings to clone story
  amoeba do
    enable

    # # indicate that this is amoeba running so videos are not re-processed
    # customize(lambda { |original_asset,new_asset|
    #   new_asset.is_amoeba = true
    # })

    clone [:medium_translations]
  end
  
  #################################
        
	def to_json(options={})
     options[:except] ||= [:created_at, :updated_at]
     super(options)
   end


  ##############################
  ## shortcut methods to get to asset objects in translation
  ##############################
  # create model variable @asset to store the asset record for later use without having to call the db again
  @image = nil
  @video = nil
  @processed = nil

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

  def video
    if @video.present?
      return @video
    else
      x = with_translation(self.current_locale, false)
      if x.present?
        @video = x.video
        return @video
      end
    end
  end

  def video_exists?
    video.present? && video.file.exists?
  end     

  def is_processed?
    if @processed.present?
      return @processed
    else
      x = with_translation(self.current_locale, false)
      if x.present?
        @processed = x.is_processed?
        return @processed
      end
    end
    return false
  end


  #################################

  # get the translation record for the given locale
  # if it does not exist, build a new one if wanted
  def with_translation(locale, build_if_missing=true)
    @local_translations ||= {}
    if @local_translations[locale].blank?
      x = self.medium_translations.where(:locale => locale).first
      if x.blank? && build_if_missing
        x = self.medium_translations.build(locale: locale)
      end

      @local_translations[locale] = x
    end
    return @local_translations[locale]
  end

private
  def image_type?    
    self.media_type == TYPE[:image]
  end
  def video_type?    
    self.media_type == TYPE[:video]
  end
end
