class MediumTranslation < ActiveRecord::Base
  belongs_to :medium

  attr_accessible :medium_id, :locale, :title, :caption, :caption_align, :source, :infobox_type

  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 255}  
  validates :caption, length: { maximum: 2000 }  

  #################################
  # settings to clone story
  amoeba do
    enable
  end

end
