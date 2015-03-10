class YoutubeTranslation < ActiveRecord::Base
  belongs_to :youtube

  attr_accessible :id, :youtube_id, :locale, :title, :url, :menu_lang, :cc, :cc_lang, :code, :loop, :info

  attr_accessor :is_progress_increment, :progress_story_id, :loop, :info

  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 255}  
  validates :url, :presence => true
  validates :url, :format => {:with => URI::regexp(['http','https']), :message => I18n.t('errors.messages.invalid_format_url') }, :if => "!url.blank?"
  validate :generate_iframe
  validates_uniqueness_of :youtube_id, scope: [:locale]
  #################################
  # settings to clone story
  amoeba do
    enable
  end

  # #################################
  # ## Callbacks

#  before_validation :generate_iframe
  def generate_iframe
    id = ''
    u = self.url 
    api_key = ENV['STORY_BUILDER_YOUTUBE_API_KEY']
    if api_key.nil?
     errors.add(:code, I18n.t('stories.youtube.generate_iframe.missing_api_key'))
     return false
    end
    if u.present?
      uri = URI.parse(u)
      if(uri.host.nil? && u.length == 11)
        id = u
      else
        uri = /^(?:http(?:s)?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:(?:watch)?\?(?:.*&)?v(?:i)?=|(?:embed|v|vi|user)\/))([^\?&\"'>]+)/.match(u)
        if(uri[1].length == 11)
          id = uri[1]
        end
      end
      if id.length == 11    
        source = "https://www.googleapis.com/youtube/v3/videos?key=#{api_key}&part=id&id=#{id}"
        result = JSON.parse(Net::HTTP.get_response(URI.parse(source)).body)

        if result['items'].present?
           self.code = id
           return true
        end
      end
    end   

     self.errors.add(:code, I18n.t('stories.youtube.generate_iframe.error'))       
     return false
  end

end
