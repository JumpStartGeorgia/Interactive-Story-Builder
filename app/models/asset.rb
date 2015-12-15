class Asset < ActiveRecord::Base
  has_attached_file :asset

  belongs_to :user, foreign_key: :item_id
  belongs_to :story, foreign_key: :item_id
  belongs_to :section, foreign_key: :item_id
  belongs_to :slideshow, foreign_key: :item_id
#  belongs_to :media, foreign_key: :item_id
  belongs_to :image, foreign_key: :item_id, class_name: "Medium"
  belongs_to :video, foreign_key: :item_id, class_name: "Medium"  
  acts_as_list scope: :slideshow

  TYPE = {story_thumbnail: 1, section_audio: 2, content_image: 3, media_image: 4, media_video: 5, slideshow_image: 6, user_avatar: 7}

  acts_as_list scope: [:item_id, :asset_type]

  validates :asset_type, :presence => true
  validates :asset_type, inclusion: { in: TYPE.values }
  

  attr_accessor :init_called, :asset_exists, :stop_check_thumbnail, :process_video, :is_video_image, :is_amoeba
  
  after_initialize :init

  before_post_process :init
  before_post_process :transliterate_file_name
  
  before_validation :set_processed_flag


  amoeba do
    enable

    # indicate that this is amoeba running so videos are not re-processed
    customize(lambda { |original_asset,new_asset|
      new_asset.is_amoeba = true
    })
  end
  
  # if the flag is not already true
  # and if this is not a video, set the flag to true
  def set_processed_flag
    if read_attribute(:processed).present? && !read_attribute(:processed) && self.asset_type != TYPE[:media_video]
      self.processed = true
    end
    return true   
  end
  
  # get the processed url of a video
  def media_video_processed_url
    if self.asset_type == TYPE[:media_video] && read_attribute(:processed).present? && self.processed == true
      self.asset.url(:processed,false).gsub(/\.[0-9a-zA-Z]+$/,".mp4")
    end
  end

  # get the formatted file name for the asset
  # - files are formatted with 'id__' pre-pended to the front of the file name for the following:
  #   - section audio
  #   - media image
  #   - media video
  #   - slideshow image
  def asset_file_name_formatted
    case self.asset_type
    when TYPE[:section_audio], TYPE[:media_image], TYPE[:media_video], TYPE[:slideshow_image]
      "#{self.id}__#{self.asset_file_name}"
    else
      self.asset_file_name
    end
  end
  
  def init
    if self.init_called != true
      # flag to record if asset exists - is used in form so can edit caption without providing new file
      self.asset_exists = self.asset_file_name.present?

      opt = {}    
      case self.asset_type
        when TYPE[:user_avatar]        
          opt = { 
            :url => "/system/users/:style/:user_avatar_file_name.:extension",
            :styles => {
                :'168x168' => {:geometry => "168x168#"},
                :'50x50' => {:geometry => "50x50#"},
                :'40x40' => {:geometry => "40x40#"}
            },
            :default_url => "/assets/missing/user_avatar/:style/default_user.png"
          }

        when TYPE[:story_thumbnail]        
          opt = { 
            :url => "/system/places/thumbnail/:item_id/:style/:basename.:extension",
            :styles => {:thumbnail => {:geometry => "459x328#"}},            
            :default_url => "/assets/missing/story_thumbnail/missing.jpg"
          }

        when  TYPE[:section_audio]         
          opt = {:url => "/system/places/audio/:story_id/:id__:basename.:extension"}  

        when  TYPE[:media_image]        
          opt = { 
                  :url => "/system/places/images/:media_image_story_id/:style/:id__:basename.:extension",
                  :styles => {
                        :mobile_640 => {:geometry => "640x427"},
                        :mobile_1024 => {:geometry => "1024x623"},
                        :fullscreen => {:geometry => "1500>"}
                }
          }  

        when  TYPE[:media_video]        
          opt = {   
                  :url => "/system/places/video/:media_video_story_id/:style/:id__:basename.:extension",
                  :styles => { 
                    :poster => { :format => 'jpg', :time => 1 }
                  }, 
                  :processors => [:ffmpeg]
          }  

         when  TYPE[:slideshow_image]        
          opt = {   
                  :url => "/system/places/slideshow/:slideshow_image_story_id/:style/:id__:basename.:extension" ,
                  :styles => {                   
                    :mobile_640 => {:geometry => "640x427"},
                    :mobile_1024 => {:geometry => "1024x623"}, 
                    :slideshow => {:geometry => "812x462"},                   
                    :thumbnail => {:geometry => "44x44^"},
                    :thumbnail_preview => {:geometry => "160x160^"}
                  },
                  :convert_options => {
                    :thumbnail => "-gravity center -extent 44x44",
                    :thumbnail_preview => "-gravity center -extent 160x160"
                  }
          }    

              
      end    

      self.asset.options.merge!(opt)

      # remember that init has already been called
      self.init_called = true
    end
  end


  with_options :if => "self.asset_type == TYPE[:user_avatar]" do |t|    
    t.validates_attachment :asset, {  :presence => true, :content_type => { :content_type => ["image/jpeg", "image/png"] }, :size => { :in => 0..4.megabytes }}  
  end
  with_options :if => "self.asset_type == TYPE[:story_thumbnail]" do |t|    
    t.validates_attachment :asset, {  :presence => true, :content_type => { :content_type => ["image/jpeg", "image/png"] }, :size => { :in => 0..4.megabytes }}  
  end
  with_options :if => "self.asset_type == TYPE[:section_audio]" do |t|      
    t.validates_attachment :asset, {   :presence => true, :content_type => { :content_type => ["audio/mp3", "audio/mpeg"] }, :size => { :in => 0..10.megabytes }}  
  end
  with_options :if => "self.asset_type == TYPE[:media_image]" do |t|      
    t.validates_attachment :asset, { :presence => true, :content_type => { :content_type => ["image/jpeg", "image/png"] }, :size => { :in => 0..4.megabytes }}  
  end
  with_options :if => "self.asset_type == TYPE[:media_video]" do |t|      
    t.validates_attachment :asset, { :presence => true, :content_type => { :content_type => ["video/mp4", "video/quicktime", "video/webm", "video/ogg", "video/x-flv", "video/avi","video/x-msvideo","video/msvideo","application/x-troff-msvideo", "video/x-ms-wmv" ]}, :size => { :in => 0..25.megabytes }}    
  end
 with_options :if => "self.asset_type == TYPE[:slideshow_image]" do |t|      
    t.validates_attachment :asset, { :presence => true, :content_type => { :content_type => ["image/jpeg", "image/png"] }, :size => { :in => 0..4.megabytes }}  
  end

   
  def transliterate_file_name
    if asset_file_name.present?
      extension = File.extname(asset_file_name).gsub(/^\.+/, '')
      filename = asset_file_name.gsub(/\.#{extension}$/, '')
      # if this is a video image, the filename includes the asset id of the video
      # - need to remove this id
      if self.asset_type == TYPE[:media_image] && self.is_video_image
        filename.gsub!(/^\d{1,}__/, '')
      end
      self.asset.instance_write(:file_name, "#{transliterate(filename)}.#{transliterate(extension)}")
    end
  end
  
  def transliterate(str)
    # Based on permalink_fu by Rick Olsen
   
    # Escape str by transliterating to UTF-8 with Iconv http://stackoverflow.com/questions/12947910/force-strings-to-utf-8-from-any-encoding
    #string.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?")
    #s = Iconv.iconv('ascii//ignore//translit', 'utf-8', str).to_s
     s = str.force_encoding("UTF-8")
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
 

  # get all of the video records for a story
  def self.videos_for_story(story_id)
    sql = "select a.* from sections as s inner join media as m on m.section_id = s.id join assets as a on a.item_id = m.id "
    sql << "where a.asset_type = "
    sql << TYPE[:media_video].to_s
    sql << " and s.story_id = ?"
    find_by_sql([sql, story_id])
  end
end
