class ContactMailer < ActionMailer::Base
  default :from => ENV['APPLICATION_FEEDBACK_FROM_EMAIL']
  default :to => ENV['APPLICATION_FEEDBACK_TO_EMAIL']

  def new_message(message)
    @message = message
    mail(:from => "#{message.name} <#{message.email}>",
			:cc => "#{message.name} <#{message.email}>",
			:subject => I18n.t("mailer.contact.contact_form.subject"))
  end


end
