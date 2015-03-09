class ThemeTranslation < ActiveRecord::Base
  belongs_to :theme
  has_permalink :create_permalink

  attr_accessible :theme_id, :name, :edition, :description, :permalink, :locale

  validates :name, :edition, :presence => true
  validates :permalink, :uniqueness => {:scope => :locale, :case_sensitive => false, :message => I18n.t('app.msgs.already_exists')}
  validates :description, length: { maximum: 160 }
  validates_uniqueness_of :theme_id, scope: [:locale]
  # permalink is in format: name-edition
  def create_permalink   
    "#{self.name.latinize.to_ascii}-#{self.edition.latinize.to_ascii}".gsub(/[^0-9A-Za-z|_\- ]/,'')
  end

  def required_data_provided?
    provided = false
    
    provided = self.name.present? && self.edition.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.name = obj.name if self.name.blank?
    self.edition = obj.edition if self.edition.blank?
    self.description = obj.description if self.description.blank?
  end

end
