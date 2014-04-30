class Medium < ActiveRecord::Base
	belongs_to :section	
  acts_as_list scope: :section
  
  has_many :asset,     
  :conditions => "asset_type = #{Asset::TYPE[:media_image]} or asset_type = #{Asset::TYPE[:media_video]}",    
  foreign_key: :item_id,
  dependent: :destroy


	TYPE = {image: 1, video: 2}

  validates :section_id, :presence => true
  validates :media_type, :presence => true, :inclusion => { :in => TYPE.values }  
  validates :title, :presence => true , length: { maximum: 255 }  
  validates :caption, length: { maximum: 2000 }  
    
  #  validates_attachment_presence :video, if:  :video_type? 


	def to_json(options={})
     options[:except] ||= [:created_at, :updated_at]
     super(options)
   end


private
  def video_type?    
    self.media_type == 2
  end
end