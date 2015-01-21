class SectionTranslation < ActiveRecord::Base
  belongs_to :section

  attr_accessible :section_id, :title, :locale

  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 255}  

  #################################
  # settings to clone story
  amoeba do
    enable
  end
end
