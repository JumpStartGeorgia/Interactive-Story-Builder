class Medium < ActiveRecord::Base
	belongs_to :section	
  acts_as_list scope: :section
  
	TYPE = {image: 1, video: 2}
	has_attached_file :image,  	
    :url => "/system/places/images/:story_id/:style/:basename.:extension",
		:styles => {
					:mobile_640 => {:geometry => "640x427"},
					:mobile_1024 => {:geometry => "1024x623"},					 				
				}

	has_attached_file :video,
	:url => "/system/places/video/:story_id/:basename.:extension"

  validates :section_id, :presence => true
  validates :media_type, :presence => true, :inclusion => { :in => TYPE.values }  
  validates :title, :presence => true , length: { maximum: 255 }  
  validates :caption, :presence => true, length: { maximum: 255 }  
    
	validates_attachment :image, :presence => true,
  	:content_type => { :content_type => ["image/jpeg"] }#, "image/gif", "image/png"
  	
  	validates_attachment :video ,
  	:content_type => { :content_type => ["video/mp4","video/ogg","video/webm"] } 


    validates_attachment_presence :video, if:  :video_type? 

	def to_json(options={})
     options[:except] ||= [:created_at, :updated_at]
     super(options)
   end

before_post_process :transliterate_file_name


require 'iconv'




   private

def transliterate_file_name

  extension = File.extname(image_file_name).gsub(/^\.+/, '')
  filename = image_file_name.gsub(/\.#{extension}$/, '')
  self.image.instance_write(:file_name, "#{StoriesHelper.transliterate(filename)}.#{StoriesHelper.transliterate(extension)}")

  if video_file_name.present?
    extension = File.extname(video_file_name).gsub(/^\.+/, '')
    filename = video_file_name.gsub(/\.#{extension}$/, '')
    self.video.instance_write(:file_name, "#{StoriesHelper.transliterate(filename)}.#{StoriesHelper.transliterate(extension)}")
  end
end

  def video_type?    
    self.media_type == 2
  end
end