class Asset < ActiveRecord::Base
  has_attached_file :asset

  belongs_to :asset_clone, foreign_key: :asset_clone_id, class_name: 'Asset'

  belongs_to :user, foreign_key: :item_id
  belongs_to :author, foreign_key: :item_id
  belongs_to :story_translation, foreign_key: :item_id
  belongs_to :section_translation, foreign_key: :item_id
  belongs_to :slideshow_translation, foreign_key: :item_id
#  belongs_to :media, foreign_key: :item_id
  belongs_to :image, foreign_key: :item_id, class_name: "MediumTranslation"
  belongs_to :video, foreign_key: :item_id, class_name: "MediumTranslation"
  belongs_to :infographic_translation, foreign_key: :item_id, class_name: "InfographicTranslation"
  belongs_to :dataset_file, foreign_key: :item_id, class_name: "InfographicTranslation"

  acts_as_list scope: :slideshow_translation
  acts_as_list scope: [:item_id, :asset_type]

  TYPE = {story_thumbnail: 1, section_audio: 2, content_image: 3, media_image: 4, media_video: 5,
          slideshow_image: 6, user_avatar: 7, author_avatar: 8, infographic: 9, infographic_dataset: 10}


  attr_accessor :init_called, :asset_exists, :stop_check_thumbnail, :process_video, :is_video_image, :is_amoeba



  #################################
  ## Validations

  validates :asset_type, :presence => true
  validates :asset_type, inclusion: { in: TYPE.values }
  validates_presence_of :asset, :unless => :asset_clone_id?

  with_options :if => "self.asset_type == TYPE[:user_avatar]" do |t|
    t.validates_attachment :asset, {  :content_type => { :content_type => ["image/jpeg", "image/png"] }, :size => { :in => 0..4.megabytes }}
  end
  with_options :if => "self.asset_type == TYPE[:author_avatar]" do |t|
    t.validates_attachment :asset, {  :content_type => { :content_type => ["image/jpeg", "image/png"] }, :size => { :in => 0..4.megabytes }}
  end
  with_options :if => "self.asset_type == TYPE[:story_thumbnail]" do |t|
    t.validates_attachment :asset, {  :content_type => { :content_type => ["image/jpeg", "image/png"] }, :size => { :in => 0..4.megabytes }}
  end
  with_options :if => "self.asset_type == TYPE[:section_audio]" do |t|
    t.validates_attachment :asset, {  :content_type => { :content_type => ["audio/mp3", "audio/mpeg"] }, :size => { :in => 0..10.megabytes }}
  end
  with_options :if => "self.asset_type == TYPE[:media_image]" do |t|
    t.validates_attachment :asset, { :content_type => { :content_type => ["image/jpeg", "image/png"] }, :size => { :in => 0..4.megabytes }}
  end
  with_options :if => "self.asset_type == TYPE[:media_video]" do |t|
    t.validates_attachment :asset, { :content_type => { :content_type => ["video/mp4", "video/quicktime", "video/webm", "video/ogg", "video/x-flv", "video/avi","video/x-msvideo","video/msvideo","application/x-troff-msvideo", "video/x-ms-wmv" ]}, :size => { :in => 0..25.megabytes }}
  end
  with_options :if => "self.asset_type == TYPE[:slideshow_image]" do |t|
    t.validates_attachment :asset, { :content_type => { :content_type => ["image/jpeg", "image/png"] }, :size => { :in => 0..4.megabytes }}
  end
  with_options :if => "self.asset_type == TYPE[:infographic]" do |t|
    t.validates_attachment :asset, { :content_type => { :content_type => ["image/jpeg", "image/png"] }, :size => { :in => 0..8.megabytes }}
  end
  with_options :if => "self.asset_type == TYPE[:infographic_dataset]" do |t|
    t.validates_attachment :asset, { :size => { :in => 0..25.megabytes }}
  end



  #################################
  ## Callbacks

  after_initialize :init

  before_post_process :init
  before_post_process :transliterate_file_name

  before_validation :set_processed_flag
  before_create :set_file_id

  after_save :set_aspectratio


  def init
    if self.init_called != true
      # flag to record if asset exists - is used in form so can edit caption without providing new file
      self.asset_exists = self.asset_file_name.present?

      opt = {}
      case self.asset_type
        when TYPE[:user_avatar]
          opt = {
            :url => "/system/users/:style/:avatar_id.:extension",
            :styles => {
                :'168x168' => {:geometry => "168x168#"},
                :'50x50' => {:geometry => "50x50#"},
                :'40x40' => {:geometry => "40x40#"}
            },
            :convert_options => {
              :'168x168' => '-quality 85',
              :'50x50' => '-quality 85',
              :'40x40' => '-quality 85'
            },
            :default_url => "/assets/missing/user_avatar/:style/default_user.png"
          }

        when TYPE[:author_avatar]
          opt = {
            :url => "/system/authors/:style/:avatar_id.:extension",
            :styles => {
                :'168x168' => {:geometry => "168x168#"},
                :'50x50' => {:geometry => "50x50#"},
                :'40x40' => {:geometry => "40x40#"}
            },
            :convert_options => {
              :'168x168' => '-quality 85',
              :'50x50' => '-quality 85',
              :'40x40' => '-quality 85'
            },
            :default_url => "/assets/missing/author_avatar/:style/default_user.png"
          }

        when TYPE[:story_thumbnail]
          opt = {
            :url => "/system/places/thumbnail/:story_id/:style/:basename.:extension",
            :styles => {
                :thumbnail => {:geometry => "459x328#"},
                :slider => {:geometry => "1500>"}
            },
            :convert_options => {
              :thumbnail => '-quality 85',
              :slider => '-quality 85'
            },
            :default_url => "/assets/missing/story_thumbnail/missing.jpg"
          }

        when  TYPE[:section_audio]
          opt = {:url => "/system/places/audio/:story_id/:id__:basename.:extension"}

        when  TYPE[:media_image]
          opt = {
              :url => "/system/places/images/:story_id/:style/:id__:basename.:extension",
              :styles => {
                    :mobile_640 => {:geometry => "640x427"},
                    :mobile_1024 => {:geometry => "1024x623"},
                    :fullscreen => {:geometry => "1500>"}
            },
            :convert_options =>
            {
              :mobile_640 => '-quality 85',
              :mobile_1024 => '-quality 85',
              :fullscreen => '-quality 85'
            },
          }

        when  TYPE[:media_video]
          opt = {
                  :url => "/system/places/video/:story_id/:style/:id__:basename.:extension",
                  :styles => {
                    :poster => { :format => 'jpg', :time => 1 }
                  },
                  :processors => [:ffmpeg]
          }

         when  TYPE[:slideshow_image]
          opt = {
            :url => "/system/places/slideshow/:story_id/:style/:id__:basename.:extension" ,
            :styles => {
              :mobile_640 => {:geometry => "640x427"},
              :mobile_1024 => {:geometry => "1024x623"},
              :slideshow => {:geometry => "812x462"},
              :thumbnail => {:geometry => "44x44^"},
              :thumbnail_preview => {:geometry => "160x160^"},
              :fullscreen => {:geometry => "1500>"}
            },
            :convert_options => {
              :mobile_640 => '-quality 85',
              :mobile_1024 => '-quality 85',
              :slideshow => '-quality 85',
              :thumbnail => "-quality 85 -gravity center -extent 44x44",
              :thumbnail_preview => "-quality 85 -gravity center -extent 160x160",
              :fullscreen => '-quality 85'
            }
          }

        when  TYPE[:infographic]
          opt = {
                  :url => "/system/places/infographic/:story_id/:style/:id__:basename.:extension",
                  :styles => {
                    :poster => {:geometry => "730x>"},
                  },
                  :convert_options => {
                    :poster => "-quality 85 -gravity north -crop 730x730+0+0"
                  },
                  :default_url => "/assets/missing/infographic/missing.jpg"
          }

        when  TYPE[:infographic_dataset]
          opt = {
                  :url => "/system/places/infographic_dataset/:story_id/:id__:basename.:extension"
          }

      end

      self.asset.options.merge!(opt)

      # remember that init has already been called
      self.init_called = true
    end
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


  # if the flag is not already true
  # and if this is not a video, set the flag to true
  def set_processed_flag
    if read_attribute(:processed).present? && !read_attribute(:processed) && self.asset_type != TYPE[:media_video]
      self.processed = true
    end
    return true
  end

  # for the assets that need the story id or asset id in the file path, set it
  def set_file_id
    case self.asset_type
      when TYPE[:user_avatar]
        self.avatar_id = SecureRandom.urlsafe_base64

      when TYPE[:author_avatar]
        self.avatar_id = SecureRandom.urlsafe_base64

      when TYPE[:story_thumbnail]
        self.story_id = self.story_translation.story_id

      when  TYPE[:section_audio]
        self.story_id = self.section_translation.section.story_id

      when  TYPE[:media_image]
        self.story_id = self.image.medium.section.story_id

      when  TYPE[:media_video]
        self.story_id = self.video.medium.section.story_id

      when  TYPE[:slideshow_image]
        self.story_id = self.slideshow_translation.slideshow.section.story_id if self.slideshow_translation.slideshow.section.present?

      when  TYPE[:infographic]
        self.story_id = self.infographic_translation.infographic.section.story_id

      when  TYPE[:infographic_dataset]
        self.story_id = self.infographic_translation.infographic.section.story_id

    end
  end

  def set_aspectratio
    if self.asset_type == TYPE[:media_image] && self.asset_clone_id.nil?
      update_column(:asset_aspectratio, Paperclip::Geometry.from_file(self.asset.path(:fullscreen)).aspect.round(2)) 
    end

    return true
  end

  # def get_orientation_class
  #   asset_orientation == 0 ? "vertical-orientation" : "horizontal-orientation"
  # end
  #################################
  # settings to clone story
  amoeba do
    enable
    nullify :story_id
    # indicate that this is amoeba running so videos are not re-processed
    customize(lambda { |original_asset,new_asset|
      new_asset.is_amoeba = true
    })

  end

  #################################

  # override the paperclip asset method
  # so can test for clone asset
  # if clone exists, use that asset,
  # else use the asset in this record
  # this_asset = instance_method(:asset)
  # define_method(:asset) do
  #   a = nil
  #   if self.asset_clone_id.present?
  #     x = self.asset_clone
  #     a = x.asset if x.present?
  #   else
  #     a = this_asset.bind(self).()
  #   end
  #   return a
  # end

  # use file to get the asset file
  # if this record is cloning another, then user the clone asset
  # else use the asset in this record
  def file
    f = nil
    if self.asset_clone_id.present?
      x = self.asset_clone
      f = x.asset if x.present?
    else
      f = self.asset
    end
    return f
  end

  # use file_file_name to get the asset file name
  # if this record is cloning another, then user the clone asset
  # else use the asset in this record
  def file_file_name
    f = nil
    if self.asset_clone_id.present?
      x = self.asset_clone
      f = x.asset_file_name if x.present?
    else
      f = self.asset_file_name
    end
    return f
  end

  # if this record is cloning another, then user the clone
  # else use this record
  def is_processed?
    self.asset_clone_id.present? && self.asset_clone.present? ? self.asset_clone.processed : self.processed
  end

  # get the processed url of a video
  def media_video_processed_url
    if self.asset_type == TYPE[:media_video] && read_attribute(:processed).present? && self.processed == true
      self.file.url(:processed,false).gsub(/\.[0-9a-zA-Z]+$/,".mp4")
    end
  end

  # get the formatted file name for the asset
  # - files are formatted with 'id__' pre-pended to the front of the file name for the following:
  #   - section audio
  #   - media image
  #   - media video
  #   - slideshow image
  #   - infographic
  #   - infographic_dataset
  def asset_file_name_formatted
    if self.asset_clone_id.present?
      x = self.asset_clone
      if x.present?
        case self.asset_type
          when TYPE[:section_audio], TYPE[:media_image], TYPE[:media_video], TYPE[:slideshow_image], TYPE[:infographic], TYPE[:infographic_dataset]
            "#{x.id}__#{x.asset_file_name}"
          else
            x.asset_file_name
        end
      end
    else
      case self.asset_type
        when TYPE[:section_audio], TYPE[:media_image], TYPE[:media_video], TYPE[:slideshow_image], TYPE[:infographic], TYPE[:infographic_dataset]
          "#{self.id}__#{self.asset_file_name}"
        else
          self.asset_file_name
      end
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
