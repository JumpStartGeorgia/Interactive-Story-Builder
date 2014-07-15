class Notification < ActiveRecord::Base
  belongs_to :user

  attr_accessible :user_id, :notification_type, :identifier
  attr_accessible :email

  validates :user_id, :notification_type, :presence => true

  TYPES = {:published_story => 1, :published_story_by_author => 2, :story_comment => 3,
           :published_news => 4, :staff_pick_selection => 5, :new_user => 6, :story_collaboration => 7}


  ###################
  # methods to get emails of users that need to be notified
  ###################
  def self.for_new_user(locale, ids)
    return get_new_user_emails(ids, locale)
  end
  def self.for_published_story(locale, author_ids, category_ids)
    return get_published_story_notifications(locale, author_ids, category_ids)
  end
  def self.for_story_comment(locale)
    return get_emails(TYPES[:story_comment], locale)
  end
  def self.for_published_news(locale)
    return get_emails(TYPES[:published_news], locale)
  end
  def self.for_staff_pick_review(locale)
    return get_staff_pick_review_emails(locale)
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
   
    # get the email address of users that have a role of staff_pick
    def self.get_staff_pick_review_emails(locale)
      emails = []
      if locale
         x = User.select("distinct email")
         .where("users.wants_notifications = 1 and users.notification_language = ? and role >= ?", locale, User::ROLES[:staff_pick])
      end

      if x.present?
         emails = x.map{|x| x.email}
      end
      return emails
    end
   
   # get notifications for users that want notifications of new stories:
   # - any new story
   # - story in category
   # - story by author
  def self.get_published_story_notifications(locale, author_ids, category_ids)
    notifications = []
    if locale
      sql = "users.wants_notifications = 1 and users.notification_language = :locale and ((notification_type = :story_type and (identifier is null "
      if category_ids.present?
        sql << "or identifier in (:category_ids) "
      end
      sql << ")) "
      if author_ids.present?
        sql << " or (notification_type = :follow_type and identifier in (:author_ids))"
      end
      sql << ")"
      
      notifications = includes(:user)
                       .where(sql, 
                          locale: locale, story_type: TYPES[:published_story], category_ids: category_ids,
                          follow_type: TYPES[:published_story_by_author], author_ids: author_ids)
    end

    return notifications
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
