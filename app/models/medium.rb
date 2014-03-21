class Medium < ActiveRecord::Base
	belongs_to :section	
	
  	#attr_accessible :image,:video
	

  	has_attached_file :image,  	
    :url => "/system/places/images/:story_id/:style/:basename.:extension",
		:styles => {
					:mobile_640 => {:geometry => "640x427"},
					:mobile_1024 => {:geometry => "1024x623"},					 				
				}
	has_attached_file :video,
	:url => "/system/places/video/:story_id/:basename.:extension"

	validates_attachment :image, :presence => true,
  	:content_type => { :content_type => ["image/jpeg"] }#, "image/gif", "image/png"
  	
  	validates_attachment :video, :presence => true,
  	:content_type => { :content_type => ["video/mp4","video/ogg","video/webm"] } 

	def to_json(options={})
     options[:except] ||= [:created_at, :updated_at]
     super(options)
   end

before_post_process :transliterate_file_name
require 'iconv'

def transliterate(str)
  # Based on permalink_fu by Rick Olsen
 
  # Escape str by transliterating to UTF-8 with Iconv http://stackoverflow.com/questions/12947910/force-strings-to-utf-8-from-any-encoding
  s = Iconv.iconv('ascii//ignore//translit', 'utf-8', str).to_s
 
  # Downcase string
  s.downcase!
 
  # Remove apostrophes so isn't changes to isnt
  s.gsub!(/'/, '')
 
  # Replace any non-letter or non-number character with a space
  s.gsub!(/[^A-Za-z0-9]+/, ' ')
 
  # Remove spaces from beginning and end of string
  s.strip!
 
  # Replace groups of spaces with single hyphen
  s.gsub!(/\ +/, '-')
 
  return s
end


   private

def transliterate_file_name
  extension = File.extname(image_file_name).gsub(/^\.+/, '')
  filename = image_file_name.gsub(/\.#{extension}$/, '')
  self.image.instance_write(:file_name, "#{transliterate(filename)}.#{transliterate(extension)}")

  extension = File.extname(video_file_name).gsub(/^\.+/, '')
  filename = video_file_name.gsub(/\.#{extension}$/, '')
  self.video.instance_write(:file_name, "#{transliterate(filename)}.#{transliterate(extension)}")
end



end





#,"video/x-msvideo"
# media.image.reprocess!
# For video:
# video/ogg
# video/mp4
# video/webm
# For audio:
# audio/ogg
# audio/mpeg
