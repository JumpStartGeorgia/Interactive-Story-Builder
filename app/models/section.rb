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
  acts_as_list scope: :story



  TYPE = {content: 1, media: 2, slideshow: 3, embed_media: 4}

  accepts_nested_attributes_for :asset, :reject_if => lambda { |c| c[:asset].blank? }

  amoeba do
    enable
    exclude_field :asset
    clone [:content, :media, :slideshow, :embed_medium]
  end

  validates :story_id, :presence => true
  validates :type_id, :presence => true, :inclusion => { :in => TYPE.values }  
  validates :title, :presence => true, length: { maximum: 255, :message => 'Title max length is 255 symbols' } 	

  def to_json(options={})
    options[:except] ||= [:created_at, :updated_at]
    super(options)
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
  def asset_exists?
      self.asset.present? && self.asset.asset.exists?
  end  
  def ok?
    if content?
      return (self.content.present? && self.content.content.present?)
    elsif media?        
        self.media.each_with_index do |m,m_i|
          if m.present?
            if m.media_type == 1
              return m.image_exists?                                
            elsif m.media_type == 2              
              return (m.image_exists? && m.video_exists?)
            end          
          else
            return false
          end
        end
    elsif slideshow?
      return self.slideshow.present? && self.slideshow.assets.present?
    elsif embed_media?
      return self.embed_medium.present? && self.embed_medium.code.present?
    end
  end
end
