class SlideshowTranslation < ActiveRecord::Base
  belongs_to :slideshow

  has_many :assets,     
    :conditions => "asset_type = #{Asset::TYPE[:slideshow_image]}",    
    foreign_key: :item_id,
    dependent: :destroy,
    :order => 'position'

  accepts_nested_attributes_for :assets, :reject_if => lambda { |c| c[:asset_clone_id].blank? && c[:asset].blank? && c[:asset_exists] != 'true' }, :allow_destroy => true

  attr_accessible :slideshow_id, :locale, :title, :caption, :assets_attributes, :description

  attr_accessor :is_progress_increment, :progress_story_id

  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 255}  

  #################################
  # settings to clone story
  amoeba do
    enable
    clone [:assets]
  end
end
