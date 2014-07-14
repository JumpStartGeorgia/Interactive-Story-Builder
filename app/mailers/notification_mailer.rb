class NotificationMailer < ActionMailer::Base
  default :from => 'test@gmail.com'
	layout 'mailer'

  def story_collaborator_invitation(message)
    @message = message
    mail(:to => "#{message.email}",
			:subject => I18n.t("mailer.notification.story_collaborator_invitation.subject"))
  end
  def send_account_created(message)
    @message = message
    mail(:bcc => "#{message.bcc}",
         :subject => I18n.t("mailer.notification.account_created.subject"))    
  end
  def send_story_published(message)
    @message = message
    mail(:bcc => "#{message.bcc}",
         :subject => I18n.t("mailer.notification.story_published.subject"))    
  end
  def send_story_commented(message)
    @message = message
    mail(:bcc => "#{message.bcc}",
         :subject => I18n.t("mailer.notification.story_commented.subject"))    
  end
  def send_publish_by_leader(message)
    @message = message
    mail(:bcc => "#{message.bcc}",
         :subject => I18n.t("mailer.notification.publish_by_leader.subject"))    
  end
  def send_news_added(message)
    @message = message
    mail(:bcc => "#{message.bcc}",
         :subject => I18n.t("mailer.notification.news_added.subject"))    
  end
end
