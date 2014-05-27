class Medium < ActiveRecord::Base
	belongs_to :section	
  acts_as_list scope: :section
    
  has_one :image,     
  :conditions => "asset_type = #{Asset::TYPE[:media_image]}",    
  foreign_key: :item_id,
  class_name: "Asset",
  dependent: :destroy

  has_one :video,     
  :conditions => "asset_type = #{Asset::TYPE[:media_video]}",    
  foreign_key: :item_id,
  class_name: "Asset",
  dependent: :destroy



	TYPE = {image: 1, video: 2}

  validates :section_id, :presence => true
  validates :media_type, :presence => true, :inclusion => { :in => TYPE.values }  
  validates :title, :presence => true , length: { maximum: 255 }  

  validates :caption, length: { maximum: 2000 }  

  validates :video, presence: true, if: :video_type?

  accepts_nested_attributes_for :image
  accepts_nested_attributes_for :video, :reject_if => lambda { |c| c[:asset].blank? }

    
	def to_json(options={})
     options[:except] ||= [:created_at, :updated_at]
     super(options)
   end
  def image_exists?
    self.image.present? && self.image.asset.exists?
  end  
  def video_exists?
    self.video.present? && self.video.asset.exists?
  end  
private
  def video_type?    
    self.media_type == 2
  end
end
