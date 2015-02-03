class Medium < ActiveRecord::Base
  include TranslationOverride

  translates :title, :caption, :caption_align, :source, :infobox_type

  acts_as_list scope: :section

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

#   #################################
#   ## Callbacks
#   before_save :check_video_date
#   after_commit :create_video_image

#   # must call before the save because after save all dirty changes are lost
#   def check_video_date
#     self.video_date_changed = video_type? && self.video.asset_updated_at_changed?
#     return true
#   end

#   # if this is a video, generate the image for the video
#   # - if the story is currently being cloned, do not do this (is_amoeba = true) 
#   #   for it will be created during the clone process
#   def create_video_image
# Rails.logger.debug "@@@@@@@@@@@@@@@@   create_video_image"
# Rails.logger.debug "@@@@@@@@@@@@@@@@   video type #{video_type?}; exists #{video_exists?}; updated ad changed #{self.video_date_changed}; is amoeba = #{self.is_amoeba}"
#     if video_type? && video_exists? && self.video_date_changed && self.is_amoeba != true
#       # get the image
#       image_file = "#{Rails.root}/public#{self.video.file.url(:poster, false)}"
# Rails.logger.debug "@@@@@@@@ file = #{image_file}"
#       # check if exists
#       if File.exists?(image_file)
# Rails.logger.debug "@@@@@@@@ file exists, saving!"
#         File.open(image_file) do |f|
#           # if image does not exist, create it
#           # else, update it
#           if self.image_exists?
#             self.image.is_video_image = true
#             self.image.asset = f
#             self.image.save            
#           else
#             self.create_image(:asset_type => Asset::TYPE[:media_image], :is_video_image => true, :asset => f)
#           end
#         end 
#       end
#     end
#     return true
#   end

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
        @video = x.asset
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
