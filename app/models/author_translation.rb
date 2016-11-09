class AuthorTranslation < ActiveRecord::Base
  belongs_to :author

  # has_permalink :create_permalink
  extend FriendlyId
  friendly_id :create_permalink, use: [:slugged, :history, :scoped], slug_column: :permalink, :scope => :locale


  attr_accessible :author_id, :name, :about, :name, :locale

  validates :name, :presence => true
  #validates :permalink, :uniqueness => {:scope => :locale, :case_sensitive => false, :message => I18n.t('app.msgs.already_exists')}
  validates_uniqueness_of :author_id, scope: [:locale]

  def required_data_provided?
    provided = false

    provided = self.name.present?

    return provided
  end

  def add_required_data(obj)
    self.name = obj.name if self.name.blank?
    self.about = obj.about if self.about.blank?
  end

  def create_permalink
    self.name.downcase.dup.latinize.to_ascii.gsub(/[^0-9A-Za-z|_\- ]/,'')
  end


end
