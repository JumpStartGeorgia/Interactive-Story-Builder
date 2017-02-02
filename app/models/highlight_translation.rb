class HighlightTranslation < ActiveRecord::Base
  belongs_to :highlight

  attr_accessible :highlight_id, :caption, :url, :locale

  validates :caption, :presence => true
  #validates :permalink, :uniqueness => {:scope => :locale, :case_sensitive => false, :message => I18n.t('app.msgs.already_exists')}
  validates_uniqueness_of :highlight_id, scope: [:locale]

  def required_data_provided?
    provided = false

    provided = self.caption.present?

    return provided
  end

  def add_required_data(obj)
    self.caption = obj.caption if self.caption.blank?
  end
end
