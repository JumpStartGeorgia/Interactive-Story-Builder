class Section < ActiveRecord::Base
  include TranslationOverride

  translates :title

  has_many :section_translations, :dependent => :destroy
  belongs_to :story
  has_one :content, dependent: :destroy
  has_one :slideshow, dependent: :destroy
  # has_one :asset,     
  #   :conditions => "asset_type = #{Asset::TYPE[:section_audio]}",    
  #   foreign_key: :item_id,
  #   dependent: :destroy

  has_one :embed_medium, dependent: :destroy
  has_many :media, :order => 'position', dependent: :destroy
  has_one :youtube, dependent: :destroy
  has_one :infographic, dependent: :destroy
  acts_as_list scope: :story

  # accepts_nested_attributes_for :asset, :reject_if => lambda { |c| c[:asset].blank? }
  accepts_nested_attributes_for :section_translations

  # attr_accessor :delete_audio

  TYPE = {content: 1, media: 2, slideshow: 3, embed_media: 4, youtube: 5, infographic: 6}
  ICONS = {
    content: 'i-content-b', 
    media: 'i-fullscreen-b', 
    slideshow: 'i-slideshow-b', 
    embed_media: 'i-embed-b',
    youtube: 'i-youtube-b',
    infographic: 'i-infographic-b'

  }

  #################################
  # settings to clone story
  amoeba do
    enable
    clone [:section_translations, :content, :media, :slideshow, :embed_medium, :youtube, :infographic]
  end

  #################################
  ## Validations
  validates :story_id, :presence => true
  validates :type_id, :presence => true, :inclusion => { :in => TYPE.values }  

  # #################################
  # ## Callbacks

  before_destroy :trigger_translation_observer, prepend: true
  def trigger_translation_observer
    self.section_translations.each do |trans|
      trans.is_progress_increment = false
    end
  end

  before_validation :trigger_delete_audio

  # have to call this in section because delete_audio is not an attribute in the table
  # and so Dirty is not applied to it.
  # can catch the flag here and then call the translation method.
  def trigger_delete_audio
    if self.section_translations.present?
      delete_audio = self.section_translations.first.delete_audio
      if delete_audio.present? && delete_audio.to_bool == true
        self.section_translations.first.check_delete_audio
      end
    end
    return true
  end

  #################################

  def to_json(options={})
    options[:except] ||= [:created_at, :updated_at]
    super(options)
  end

  def get_icon
    key = get_str_type
    if key.present?
      ICONS[key]
    end
  end

  def get_str_type
  	 TYPE.keys[TYPE.values.index(self.type_id)]
  end

  ##############################
  ## shortcut methods to get to asset objects in translation
  ##############################
  # create model variable @asset to store the asset record for later use without having to call the db again
  @asset = nil

  def asset
    if @asset.present?
      return @asset
    else
      x = with_translation(self.current_locale)
      if x.present?
        @asset = x.asset
        return @asset
      end
    end
  end

  def asset_exists?
    asset.present? && asset.file.exists?
  end     

  #################################

  # get the translation record for the given locale
  # if it does not exist, build a new one if wanted
  def with_translation(locale, build_if_missing=true)
    @local_translations ||= {}
    if @local_translations[locale].blank?
      x = self.section_translations.where(:locale => locale).first
      if x.blank? && build_if_missing
        x = self.section_translations.build(locale: locale)
      end

      @local_translations[locale] = x
    end
    return @local_translations[locale]
  end

  ##############################

  def content?
  	 TYPE[:content] == self.type_id	
  end
  def media?
   	 TYPE[:media] == self.type_id	
  end
  def slideshow?
     TYPE[:slideshow] == self.type_id 
  end
  def embed_media?
     TYPE[:embed_media] == self.type_id 
  end
  def youtube?
     TYPE[:youtube] == self.type_id 
  end
  def infographic?
     TYPE[:infographic] == self.type_id 
  end


  def ok?
    if content?
      return (self.content.present? && self.content.text.present?)
    elsif media?        
        exists = []
        self.media.each_with_index do |m,m_i|
          if m.present?
            if m.media_type == Medium::TYPE[:image]
              exists << m.image_exists?                                
            elsif m.media_type == Medium::TYPE[:video]
              exists << (m.image_exists? && m.video_exists?)
            end          
          else
            exists << false
          end
        end
        return !exists.include?(false)
    elsif slideshow?
      return self.slideshow.present? && self.slideshow.asset_files.present?
    elsif embed_media?
      return self.embed_medium.present? && self.embed_medium.code.present?
    elsif youtube?
      return self.youtube.present? && self.youtube.code.present?
    elsif infographic?
      return self.infographic.present? && 
            (self.infographic.static_type? && self.infographic.image.present?) ||
            (self.infographic.dynamic_type? && self.infographic.dynamic_url.present?)
    end
  end
end
