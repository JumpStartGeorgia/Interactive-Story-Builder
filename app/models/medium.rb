class Medium < ActiveRecord::Base
	belongs_to :section	
	
  	#attr_accessible :image,:video
  
  	has_attached_file :image,
    :url => "/system/places/:story_id/images/:id_:style.:extension",
		:styles => {
					:thumb => {:geometry => "200x200>"},
					:medium => {:geometry => "450x450>"},
					:large => {:geometry => "900x900>"}
				}
	has_attached_file :video,
	:url => "/system/places/:story_id/video/:id.:extension"

	validates_attachment :image, :presence => true,
  	:content_type => { :content_type => ["image/jpeg", "image/gif", "image/png"] }
  	
  	validates_attachment :video, :presence => true,
  	:content_type => { :content_type => ["video/mp4","video/ogg","video/webm"] } #,"video/x-msvideo"

	def to_json(options={})
     options[:except] ||= [:created_at, :updated_at]
     super(options)
   end
end


# media.image.reprocess!
# For video:
# video/ogg
# video/mp4
# video/webm
# For audio:
# audio/ogg
# audio/mpeg
