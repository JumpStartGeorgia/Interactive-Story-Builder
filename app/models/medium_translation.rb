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


  #################################
  # setting fields must be integers but have to store as strings 
  # for globalize gem to work
  # so override get methods and make integers
  def caption_align
    if self.read_attribute(:caption_align).present?
      self.read_attribute(:caption_align).to_i
    end
  end
  def infobox_type
    if self.read_attribute(:infobox_type).present?
      self.read_attribute(:infobox_type).to_i
    end
  end

end
