class ContactMailer < ActionMailer::Base
  default :from => ENV['STORY_BUILDER_FROM_EMAIL']
  default :to => ENV['STORY_BUILDER_TO_EMAIL']

  def new_message(message)
    @message = message
    mail(:cc => "#{message.name} <#{message.email}>",
			:subject => I18n.t("mailer.contact.contact_form.subject"))
  end


end
