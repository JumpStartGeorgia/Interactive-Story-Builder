class YoutubeTranslation < ActiveRecord::Base
  attr_accessible :id, :youtube_id, :locale, :menu_lang, :cc, :cc_lang, :code
  belongs_to :youtube
end
