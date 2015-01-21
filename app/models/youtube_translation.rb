class YoutubeTranslation < ActiveRecord::Base
  belongs_to :youtube

  attr_accessible :id, :youtube_id, :locale, :title, :url, :menu_lang, :cc, :cc_lang, :code

  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 255}  
  validates :url, :presence => true
  validates :url, :format => {:with => URI::regexp(['http','https'])}, :if => "!url.blank?"

  #################################
  # settings to clone story
  amoeba do
    enable
  end
end
