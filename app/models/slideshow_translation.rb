class SlideshowTranslation < ActiveRecord::Base
  belongs_to :slideshow

  attr_accessible :slideshow_id, :locale, :title, :caption

  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 255}  

  #################################
  # settings to clone story
  amoeba do
    enable
  end
end
