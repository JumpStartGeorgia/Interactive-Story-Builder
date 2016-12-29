class Logo < ActiveRecord::Base
  LOGO_TYPE = {sponsor: 1, partner: 2}

  acts_as_list scope: [:logo_type]

  has_attached_file :image, 
    :url => "/system/logos/:id/:style/:basename.:extension",
    styles: { medium: "200x" },
    :convert_options => {:'medium' => '-quality 85'}

  attr_accessible :logo_type, :image, :is_active, :position, :url

  validates :logo_type, :url, presence: true
  validates :logo_type, inclusion: { in: LOGO_TYPE.values }
  validates :url, :format => {:with => URI::regexp(['http','https']), :message => I18n.t('errors.messages.invalid_format_url') }, :if => "!url.blank?"
  validates_attachment :image, presence: true,
                                content_type: { content_type: /\Aimage\/.*\z/ },
                                size: { in: 0..4.megabytes }

  #############################
  ## SCOPES
  scope :active, where(is_active: true)
  scope :sorted, order('is_active desc, position asc, id asc')
  scope :sponsors, where(logo_type: LOGO_TYPE[:sponsor])
  scope :partners, where(logo_type: LOGO_TYPE[:partner])


  def logo_type_name
    key = LOGO_TYPE.keys[LOGO_TYPE.values.index(self.logo_type)]
    if key.present?
      return I18n.t("app.common.logo_types.#{key}")
    else
      return nil
    end
  end

  def logo_type_name_plural
    key = LOGO_TYPE.keys[LOGO_TYPE.values.index(self.logo_type)]
    if key.present?
      return I18n.t("app.common.logo_types.#{key}s")
    else
      return nil
    end
  end
end
