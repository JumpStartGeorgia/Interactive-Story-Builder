class Medium < ActiveRecord::Base
	belongs_to :section	
	
  	attr_accessible :image
  
  	has_attached_file :image,
    :url => "/system/places/:story_id/images/:id_:style.:extension",
		:styles => {
					:thumb => {:geometry => "200x200>"},
					:medium => {:geometry => "450x450>"},
					:large => {:geometry => "900x900>"}
				}


	def to_json(options={})
     options[:except] ||= [:created_at, :updated_at]
     super(options)
   end
end
