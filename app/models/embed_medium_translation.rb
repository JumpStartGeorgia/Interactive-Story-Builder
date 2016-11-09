class EmbedMediumTranslation < ActiveRecord::Base
  belongs_to :embed_medium

  attr_accessible :sembed_medium_id, :title, :url, :code, :locale

  attr_accessor :is_progress_increment, :progress_story_id

  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 255}
  validates :code, :presence => true
  validates :url, :format => {:with => URI::regexp(['http','https']), :message => I18n.t('errors.messages.invalid_format_url') }, :if => "!url.blank?"
  validates_uniqueness_of :embed_medium_id, scope: [:locale]
  #################################
  # settings to clone story
  amoeba do
    enable
  end

end
