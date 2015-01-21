class EmbedMediumTranslation < ActiveRecord::Base
  belongs_to :sembed_medium

  attr_accessible :sembed_medium_id, :title, :url, :code, :locale

  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 255}  
  validates :url, :code, :presence => true
  validates :url, :format => {:with => URI::regexp(['http','https'])}, :if => "!url.blank?"

  #################################
  # settings to clone story
  amoeba do
    enable
  end
end
