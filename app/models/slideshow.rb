class Slideshow < ActiveRecord::Base
	belongs_to :section	  	
	has_many :assets,     
	  :conditions => "asset_type = #{Asset::TYPE[:slideshow_image]}",    
	  foreign_key: :item_id,
	  dependent: :destroy


	validates :section_id, :presence => true  
	validates :title, :presence => true , length: { maximum: 255 }  

	accepts_nested_attributes_for :assets, :reject_if => lambda { |c| c[:asset].blank? }, :allow_destroy => true
end
