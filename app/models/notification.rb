class Notification < ActiveRecord::Base
  belongs_to :user

  attr_accessible :user_id, :notification_type, :identifier
  attr_accessible :email

  validates :user_id, :notification_type, :presence => true

  TYPES = {:new_user => 1, :published_story => 2, :new_story_followed_user => 3, :story_comment => 4, :published_news => 5, :staff_pick_selection => 6, :story_collaboration => 7}

  def self.for_new_user(locale, ids)
    return get_new_user_emails(ids, locale)
  end
  def self.for_published_story(locale)
    return get_emails(TYPES[:published_story], locale)
  end
  def self.for_new_story_followed_user(locale)
    return get_emails(TYPES[:new_story_followed_user], locale)
  end
  def self.for_story_comment(locale)
    return get_emails(TYPES[:story_comment], locale)
  end
  def self.for_published_news(locale)
    return get_emails(TYPES[:published_news], locale)
  end
  def self.for_staff_pick_selection(locale)
    return get_emails(TYPES[:staff_pick_selection], locale)
  end
  def self.for_story_collaboration(locale)
    return get_emails(TYPES[:story_collaboration], locale)
  end

protected

    # get the email address of new users so they can be notified
    def self.get_new_user_emails(ids, locale)
      emails = []
      if ids && locale
         x = User.select("distinct email")
         .where(:wants_notifications => true, :notification_language => locale, :id => ids)         
      end

      if x.present?
         emails = x.map{|x| x.email}
      end
      return emails
   end
   
   # get email address of users that want a specific notification
   def self.get_emails(type, locale)
      emails = []
      if type && locale
         x = select("distinct users.email").joins(:user)
         .where("users.wants_notifications = 1 and users.notification_language = ? and notification_type = ?", locale, type)
      end

      if x.present?
         emails = x.map{|x| x.email}
      end
      return emails
   end

end
