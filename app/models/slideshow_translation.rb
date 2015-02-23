class SlideshowTranslation < ActiveRecord::Base
  belongs_to :slideshow

  has_many :asset_files,     
    :conditions => "asset_type = #{Asset::TYPE[:slideshow_image]}",    
    foreign_key: :item_id,
    dependent: :destroy,
    :order => 'position',
    class_name: "Asset"

  accepts_nested_attributes_for :asset_files, :reject_if => lambda { |c| c[:asset_clone_id].blank? && c[:asset].blank? && c[:asset_exists] != 'true' }, :allow_destroy => true

  attr_accessible :slideshow_id, :locale, :title, :caption, :asset_files_attributes, :description

  attr_accessor :is_progress_increment, :progress_story_id

  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 255}  
  validates_length_of :asset_files, :minimum => 1, :message => I18n.t('activerecord.errors.messages.not_provided')
  #################################
  # settings to clone story
  amoeba do
    enable
    clone [:asset_files]
  end
end
