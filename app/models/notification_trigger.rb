class NotificationTrigger < ActiveRecord::Base
  attr_accessible :identifier, :notification_type
   scope :not_processed, where(:processed => false)
  #TYPES = {:account_created => 1, :story_published => 2, :story_commented => 3, :publish_by_leader => 4, :news_added => 5 }
  def self.process_all_types
    process_account_created   
  end

  #################
  ## change vote
  #################
  def self.add_account_created(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:account_created], :identifier => id)
  end

  def self.process_account_created
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:change_vote]).not_processed

    if triggers.present?
      I18n.available_locales.each do |locale|
        message = Message.new
         message.bcc = Notification.change_vote(locale)
        if message.bcc.length > 0
           message.locale = locale
           message.subject = I18n.t("mailer.notification.change_vote.subject", :locale => locale)
           message.message = I18n.t("mailer.notification.change_vote.message", :locale => locale)
          message.message2 = []

          triggers.map{|x| x.identifier}.uniq.each do |id|
            agenda = Agenda.not_deleted.find_by_id(id)
            if agenda.present?
              message.message2 << ["#{agenda.official_law_title.present? ? agenda.official_law_title : agenda.name} (#{agenda.session_number})", agenda.id]
              end
           end

          NotificationMailer.change_vote(message).deliver if message.message2.present?
        end
      end

      # mark these as processed
      NotificationTrigger.where(:id => triggers.map{|x| x.id}).update_all(:processed => true)

    end



      # message = Message.new
      # message.email = user.email
      #    message.locale = user.notification_language
      #    message.subject = I18n.t("mailer.notification.new_user.subject", :locale => user.notification_language)
      #    message.message = I18n.t("mailer.notification.new_user.message", :locale => user.notification_language)
      #    NotificationMailer.new_user(message).deliver
      #    user.send_notification = false # make sure duplicate messages are not sent
  end

end
