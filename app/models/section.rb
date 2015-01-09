class Section < ActiveRecord::Base
  belongs_to :story
  has_one :content, dependent: :destroy
  has_one :slideshow, dependent: :destroy
  has_one :asset,     
    :conditions => "asset_type = #{Asset::TYPE[:section_audio]}",    
    foreign_key: :item_id,
    dependent: :destroy

  has_one :embed_medium, dependent: :destroy
  has_many :media, :order => 'position', dependent: :destroy
  has_one :youtube, dependent: :destroy
  acts_as_list scope: :story

  attr_accessor :delete_audio

  TYPE = {content: 1, media: 2, slideshow: 3, embed_media: 4, youtube: 5}
  ICONS = {
    content: 'i-content-b', 
    media: 'i-fullscreen-b', 
    slideshow: 'i-slideshow-b', 
    embed_media: 'i-embed-b',
    youtube: 'i-youtube-b'

  }

  accepts_nested_attributes_for :asset, :reject_if => lambda { |c| c[:asset].blank? }

  amoeba do
    enable
    clone [:content, :media, :slideshow, :embed_medium, :youtube]
  end

  validates :story_id, :presence => true
  validates :type_id, :presence => true, :inclusion => { :in => TYPE.values }  
  validates :title, :presence => true, length: { maximum: 255, :message => 'Title max length is 255 symbols' } 	

  before_save :check_delete_audio

  # if delete_audio flag set, then delete the audio asset
  def check_delete_audio
    logger.debug "///////////// check_delete_audio start"
    logger.debug "///////////// delete_audio = #{delete_audio.present? && delete_audio.to_bool}; asset present = #{self.asset.present?}"
    if delete_audio.present? && delete_audio.to_bool == true && self.asset.present?
      logger.debug "///////////// - deleting audio!"
      self.asset.destroy
    end
  end  

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
  def asset_exists?
      self.asset.present? && self.asset.asset.exists?
  end  
  def ok?
    # todo maybe code should be added for youtube
    if content?
      return (self.content.present? && self.content.content.present?)
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
      return self.slideshow.present? && self.slideshow.assets.present?
    elsif embed_media?
      return self.embed_medium.present? && self.embed_medium.code.present?
   elsif youtube?
      return self.youtube.present? #&& self.youtube.code.present?
    end
  end
end
