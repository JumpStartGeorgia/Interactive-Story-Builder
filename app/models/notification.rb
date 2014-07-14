class Notification < ActiveRecord::Base
   belongs_to :user

  	attr_accessible :user_id, :notification_type, :identifier
   attr_accessible :email

   validates :user_id, :notification_type, :presence => true

   TYPES = {:account_created => 1, :story_published => 2, :story_commented => 3, :publish_by_leader => 4, :news_added => 5 }

   def self.for_account_created(locale,ids)
      return get_user_emails(ids, locale)
   end
   def self.for_story_published(locale)
      return get_emails(TYPES[:story_published], locale)
   end
   def self.for_story_commented(locale)
      return get_emails(TYPES[:story_commented], locale)
   end
   def self.for_publish_by_leader(locale)
      return get_emails(TYPES[:publish_by_leader], locale)
   end
   def self.for_news_added(locale)
      return get_emails(TYPES[:news_added], locale)
   end

protected

    def self.get_user_emails(ids, locale)
      emails = []
      if ids && locale
         x = User.select("email")
         .where(:wants_notifications => true, :notification_language => locale, :id => ids)         
      end

      if x && !x.empty?
         emails = x.map{|x| x.email}
      end
      return emails
   end
   def self.get_emails(type, locale)
      emails = []
      if type && locale
         x = select("users.email").joins(:user)
         .where("users.wants_notifications = 1 and users.notification_language = ? and notification_type = ?", locale, type)
      end

      if x && !x.empty?
         emails = x.map{|x| x.email}
      end
      return emails
   end

end