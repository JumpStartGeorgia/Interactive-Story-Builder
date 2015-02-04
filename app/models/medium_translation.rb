class MediumTranslation < ActiveRecord::Base
  belongs_to :medium

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

  accepts_nested_attributes_for :image, :reject_if => lambda { |c| c[:asset].blank? && c[:asset_clone_id].blank? }
  accepts_nested_attributes_for :video, :reject_if => lambda { |c| c[:asset].blank? && c[:asset_clone_id].blank? }

  attr_accessible :medium_id, :locale, :title, :caption, :caption_align, :source, :infobox_type, 
                  :media_type, :image_attributes, :video_attributes
  attr_accessor :video_date_changed, :is_amoeba, :progress_action

  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 255}  
  validates :caption, length: { maximum: 2000 }  

  validates :image, presence: true, if: :image_type?
  validates :video, presence: true, if: :video_type?

  #################################
  ## Callbacks
  before_save :check_video_date
  after_commit :create_video_image

  # must call before the save because after save all dirty changes are lost
  def check_video_date
    self.video_date_changed = video_type? && self.video.asset_updated_at_changed?
    return true
  end

  # if this is a video, generate the image for the video
  # - if the story is currently being cloned, do not do this (is_amoeba = true) 
  #   for it will be created during the clone process
  def create_video_image
Rails.logger.debug "@@@@@@@@@@@@@@@@   create_video_image"
Rails.logger.debug "@@@@@@@@@@@@@@@@   video type #{video_type?}; exists #{video_exists?}; updated ad changed #{self.video_date_changed}; is amoeba = #{self.is_amoeba}"
    if video_type? && video_exists? && self.video_date_changed && self.is_amoeba != true
      # get the image
      image_file = "#{Rails.root}/public#{self.video.file.url(:poster, false)}"
Rails.logger.debug "@@@@@@@@ file = #{image_file}"
      # check if exists
      if File.exists?(image_file)
Rails.logger.debug "@@@@@@@@ file exists, saving!"
        File.open(image_file) do |f|
          # if image does not exist, create it
          # else, update it
          if self.image_exists?
            self.image.is_video_image = true
            self.image.asset = f
            self.image.save            
          else
            self.create_image(:asset_type => Asset::TYPE[:media_image], :is_video_image => true, :asset => f)
          end
        end 
      end
    end
    return true
  end


  #################################
  # settings to clone story
  amoeba do
    enable

    # indicate that this is amoeba running so videos are not re-processed
    customize(lambda { |original_asset,new_asset|
      new_asset.is_amoeba = true
    })

    clone [:image, :video]
  end

  #################################

  def image_exists?
    self.image.present? && self.image.file.exists?
  end  

  def video_exists?
    self.video.present? && self.video.file.exists?
  end  

  def is_processed?
    puts "====== trans is processed"
    if video_type?
      puts "- video"
      video_exists? && self.video.processed
    elsif image_type?
      puts "- image"
      image_exists? && self.image.processed 
    end
  end

private
  def image_type?    
    self.media_type == Medium::TYPE[:image]
  end
  def video_type?    
    self.media_type == Medium::TYPE[:video]
  end

end
