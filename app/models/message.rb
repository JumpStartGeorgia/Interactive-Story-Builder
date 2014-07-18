class Message
 	include ActiveAttr::Model
  include ActiveAttr::MassAssignment
  include ActiveModel::Validations
  include ActiveRecord::Callbacks

	attribute :name
	attribute :email
	attribute :message
	attribute :message_list
	attribute :subject
	attribute :bcc
	attribute :locale, :default => I18n.locale
  attribute :message_type
  attribute :mailer_type
  
	attr_accessor :name, :email, :message, :subject, :bcc, :locale, :message_type, :mailer_type, :message_list
  before_validation :strip_whitespace
  TYPE = {:bug => 1, :feature => 2, :feedback => 3}
  MAILER_TYPE = {:feedback => 1, :notification => 2}

#  validates_presence_of :email, :message => I18n.t('activerecord.errors.models.message.attributes.email.blank')
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates_presence_of :message, :if => :is_feedback?
  validates_length_of :message, :maximum => 500
  validates_presence_of :message_type, :if => :is_feedback?

  def is_feedback?
    self.mailer_type == MAILER_TYPE[:feedback]
  end

  def get_type_name
    if self.message_type
      index = TYPE.values.index{|x| x.to_s == self.message_type.to_s}
      if index.present?
        I18n.t("message_types.#{TYPE.keys[index]}")
      end
    end
  end
  
  private
  def strip_whitespace 
    name.strip! if name.present?
    email.strip! if email.present?
  end

end
