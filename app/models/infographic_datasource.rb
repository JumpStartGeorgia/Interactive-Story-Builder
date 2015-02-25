class InfographicDatasource < ActiveRecord::Base
  belongs_to :infographic_translation
  attr_accessible :infographic_translation_id, :name, :url

  #################################
  ## Validations
  validates :name, :presence => true
  validates :url, :format => {:with => URI::regexp(['http','https']), :message => I18n.t('errors.messages.invalid_format_url') }, :if => "!url.blank?"


end