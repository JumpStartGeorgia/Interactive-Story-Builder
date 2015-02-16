class SectionTranslation < ActiveRecord::Base

  belongs_to :section
  has_one :asset,     
    :conditions => "asset_type = #{Asset::TYPE[:section_audio]}",    
    foreign_key: :item_id,
    dependent: :destroy
  accepts_nested_attributes_for :asset, :reject_if => lambda { |c| c[:asset].blank? && c[:asset_clone_id].blank? }

#  attr_accessible :section_id, :title, :locale, :asset_attributes, :delete_audio
  attr_accessor :delete_audio, :is_progress_increment, :progress_story_id


  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 255}  

  #################################
  ## Callbacks
  before_save :check_delete_audio
  # if delete_audio flag set, then delete the audio asset
  def check_delete_audio
    #logger.debug "///////////// check_delete_audio start"
    #logger.debug "///////////// delete_audio = #{delete_audio.present? && delete_audio.to_s.to_bool}; asset present = #{self.asset.present?}"
    if delete_audio.present? && delete_audio.to_s.to_bool == true && self.asset.present?
      #logger.debug "///////////// - deleting audio!"
      self.asset.destroy
    end
  end  

  #################################
  # settings to clone story
  amoeba do
    enable
  end
end
