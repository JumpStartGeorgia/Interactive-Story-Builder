class Asset < ActiveRecord::Base

  belongs_to :story
  belongs_to :section, foreign_key: :item_id
  validates :item_id,:asset_type, :presence => true
  TYPE = {story_thumbnail: 1, section_audio: 2, content_image: 3, media_image: 4, media_video: 5, slideshow_image: 6}

  after_initialize :init


  def init

     opt = {}
        logger.debug(self.inspect +  "-"*30)
    logger.debug(self.asset.options.to_s + "-"*30)
    case self.asset_type
      when Asset::TYPE[:story_thumbnail]
        logger.debug("1" + "-"*30)
        opt = { 
          :url => "/system/places/thumbnail/:id/:style/:basename.:extension",
          :styles => {:"250x250" => {:geometry => "250x250"}},
          :default_url => "/assets/missing/250x250/missing.png"
        }
      when  Asset::TYPE[:section_audio]
         logger.debug("2" + "-"*30)
        opt = {:url => "/system/places/audio/:story_id_from_parent/:basename.:extension"}  
    end    
    self.asset.options.merge!(opt)
  
    logger.debug(self.asset.options.to_s + "-"*30)
  end

  require 'iconv'


  def asset_validation
    logger.debug("-"*30)
    val = {}
    
    case self.asset_type
      when Asset::TYPE[:story_thumbnail]
        val = { :content_type => { :content_type => ["image/jpeg", "image/png"] }}
      when  Asset::TYPE[:section_audio]
        val = { :content_type => { :content_type => ["audio/mp3"] }}  
    end

   return val
  end


  has_attached_file :asset
  
    #validates_attachment :asset, asset_validation

   
  before_post_process :transliterate_file_name
  
  def transliterate_file_name
    if asset_file_name.present?
      extension = File.extname(asset_file_name).gsub(/^\.+/, '')
      filename = asset_file_name.gsub(/\.#{extension}$/, '')
      self.asset.instance_write(:file_name, "#{transliterate(filename)}.#{transliterate(extension)}")
    end
  end
  
  def transliterate(str)
    # Based on permalink_fu by Rick Olsen
   
    # Escape str by transliterating to UTF-8 with Iconv http://stackoverflow.com/questions/12947910/force-strings-to-utf-8-from-any-encoding
    #string.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?")
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
 

end