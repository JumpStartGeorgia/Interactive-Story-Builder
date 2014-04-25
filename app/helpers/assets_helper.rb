module AssetsHelper
	TYPE = {story_thumbnail: 1, section_audio: 2, content_image: 3, media_image: 4, media_video: 5, slideshow_image: 6}
	PATH = 
	{
		story_thumbnail:  "/system/places/thumbnail/:id/:style/:basename.:extension",
		section_audio: 2, 
		content_image: 3, 
		media_image: 4, 
		media_video: 5, 
		slideshow_image: 6
	}
	def get_path(type)
		  {:url => "/system/places/thumbnail/:id/:style/:basename.:extension",
			  :styles => {:"250x250" => {:geometry => "250x250"}},
			  :default_url => "/assets/missing/250x250/missing.png" } 
	end

end
