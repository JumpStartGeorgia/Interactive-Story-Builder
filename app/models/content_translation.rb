class ContentTranslation < ActiveRecord::Base
  belongs_to :content

  attr_accessible :content_id, :title, :caption, :sub_caption, :text, :locale

  attr_accessor :is_progress_increment, :progress_story_id

  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 255 }   
  validates :caption, length: { maximum: 255}   
  validates :sub_caption, length: { maximum: 255}   
  validates :text, :presence => true   

  #################################
  # settings to clone story
  amoeba do
    enable
  end
end
