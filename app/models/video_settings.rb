class VideoSettings < ActiveRecord::Base
  attr_accessible :cc, :cc_lang, :fullscreen, :info, :lang, :loop
end
