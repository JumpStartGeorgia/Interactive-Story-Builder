class Slideshow < ActiveRecord::Base
  translates :title, :caption

	belongs_to :section	  	
	has_many :assets,     
	  :conditions => "asset_type = #{Asset::TYPE[:slideshow_image]}",    
	  foreign_key: :item_id,
	  dependent: :destroy,
	  :order => 'position'

  accepts_nested_attributes_for :assets, :reject_if => lambda { |c| c[:asset].blank? && c[:asset_exists] != 'true' }, :allow_destroy => true

  has_many :slideshow_translations, :dependent => :destroy
  accepts_nested_attributes_for :slideshow_translations
  attr_accessible :slideshow_translations_attributes

  #################################
  ## Validations
	validates :section_id, :presence => true  

  #################################
  # settings to clone story
  amoeba do
    enable
    clone [:slideshow_translations, :assets]
  end
end
