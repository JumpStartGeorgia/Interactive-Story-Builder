class NotificationTrigger < ActiveRecord::Base
  attr_accessible :identifier, :notification_type
   scope :not_processed, where(:processed => false)
  #TYPES = {:account_created => 1, :story_published => 2, :story_commented => 3, :publish_by_leader => 4, :news_added => 5 }
  def self.process_all_types
    process_account_created  
    process_story_published 
  end

  #################
  ## account_created
  #################
  def self.add_account_created(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:account_created], :identifier => id)
  end

  def self.process_account_created
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:account_created]).not_processed    
    if triggers.present?
      I18n.available_locales.each do |locale|          
        message = Message.new
        message.bcc = Notification.for_account_created(locale,triggers.map{|x| x.identifier})
        if message.bcc.length > 0
          message.locale = locale
          message.subject = I18n.t("mailer.notification.account_created.subject", :locale => locale)
          message.message = I18n.t("mailer.notification.account_created.message", :locale => locale)                  
          NotificationMailer.send_account_created(message).deliver
        end
      end
      NotificationTrigger.where(:id => triggers.map{|x| x.id}).update_all(:processed => true)
    end
  end

  #################
  ## story_published
  #################
  def self.add_story_published(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:story_published], :identifier => id)
  end

  def self.process_story_published
    # TODO
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:story_published]).not_processed    
    if triggers.present?
      I18n.available_locales.each do |locale|          
        message = Message.new
        message.bcc = Notification.for_story_published(locale,triggers.map{|x| x.identifier})
        if message.bcc.length > 0
          message.locale = locale
          message.subject = I18n.t("mailer.notification.story_published.subject", :locale => locale)
          message.message = I18n.t("mailer.notification.story_published.message", :locale => locale)                  
          NotificationMailer.send_story_published(message).deliver
        end
      end
      NotificationTrigger.where(:id => triggers.map{|x| x.id}).update_all(:processed => true)
    end
  end


   # def self.send_account_created(locale)
   #    return get_emails(TYPES[:account_created], locale)
   # end
   # def self.send_story_published(locale)
   #    return get_emails(TYPES[:story_published], locale)
   # end
   # def self.send_story_commented(locale)
   #    return get_emails(TYPES[:story_commented], locale)
   # end
   # def self.send_publish_by_leader(locale)
   #    return get_emails(TYPES[:publish_by_leader], locale)
   # end
   # def self.send_news_added(locale)



end
