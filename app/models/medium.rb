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

  validates :image, presence: true, if: :image_type?
  validates :video, presence: true, if: :video_type?

  accepts_nested_attributes_for :image, :reject_if => lambda { |c| c[:asset].blank? }
  accepts_nested_attributes_for :video, :reject_if => lambda { |c| c[:asset].blank? }

  after_commit :create_video_image

  # if this is a video, generate the image for the video
  def create_video_image
    if video_type? && video_exists?
      # get the image
      image_file = "#{Rails.root}/public#{self.video.asset.url(:poster, false)}"
      # check if exists
      if File.exists?(image_file)
        File.open(image_file) do |f|
          # if image does not exist, create it
          # else, update it
          if self.image_exists?
            self.image.asset = f
            self.image.save            
          else
            self.create_image(:asset_type => Asset::TYPE[:media_image], :asset => f)
          end
        end 
      end
    end
  end
    
    
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
  def image_type?    
    self.media_type == TYPE[:image]
  end
  def video_type?    
    self.media_type == TYPE[:video]
  end
end
