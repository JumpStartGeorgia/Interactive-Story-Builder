class NotificationMailer < ActionMailer::Base
  default :from => ENV['APPLICATION_FEEDBACK_FROM_EMAIL']
	layout 'mailer'

  def story_collaborator_invitation(message)
    @message = message
    mail(:to => "#{message.email}",
			:subject => I18n.t("mailer.notification.story_collaborator_invitation.subject"))
  end

end
