class Message
	include ActiveAttr::Model
  include ActiveModel::Validations

	attribute :name
	attribute :email
	attribute :message
	attribute :subject
	attribute :bcc
	attribute :locale, :default => I18n.locale
  attribute :message_type
  
	attr_accessible :name, :email, :message, :subject, :bcc, :locale, :message_type

  TYPE = {:bug => 1, :feature => 2, :feedback => 3}

#  validates_presence_of :email, :message => I18n.t('activerecord.errors.models.message.attributes.email.blank')
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates_presence_of :message
  validates_length_of :message, :maximum => 500
  validates_presence_of :message_type

  def get_type_name
    if self.message_type
      index = TYPE.values.index{|x| x.to_s == self.message_type.to_s}
      if index.present?
        I18n.t("message_types.#{TYPE.keys[index]}")
      end
    end
  end
  
end
