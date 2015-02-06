class Notification < ActiveRecord::Base
  belongs_to :user

  attr_accessible :user_id, :notification_type, :identifier
  attr_accessible :email

  validates :user_id, :notification_type, :presence => true

  # TYPES = {:published_story => 1, :published_story_by_author => 2, :story_comment => 3,
  #          :published_news => 4, :staff_pick_selection => 5, :new_user => 6, :story_collaboration => 7, :processed_videos => 8}

  TYPES = {:published_theme => 1, :published_story_by_author => 2, :story_comment => 3,
           :new_user => 6, :story_collaboration => 7, :processed_videos => 8}


  # see if user already following another user
  def self.already_following_user(user_id, follow_user_id)
    found = false
    if user_id.present? && follow_user_id.present?
      found = where(:notification_type => TYPES[:published_story_by_author], :user_id => user_id, :identifier => follow_user_id).present?
    end
    return found
  end

  # register a user to follow another user
  def self.add_follow_user(user_id, follow_user_id)
    if user_id.present? && follow_user_id.present?
      create(:notification_type => TYPES[:published_story_by_author], :user_id => user_id, :identifier => follow_user_id)
    end
  end

  # delete notification of user following another user
  def self.delete_follow_user(user_id, follow_user_id)
    if user_id.present? && follow_user_id.present?
      where(:notification_type => TYPES[:published_story_by_author], :user_id => user_id, :identifier => follow_user_id).delete_all
    end
  end

  ###################
  # methods to get emails of users that need to be notified
  ###################
  def self.for_new_user(locale, ids)
    return get_new_user_emails(ids, locale)
  end
  def self.for_published_theme(locale, author_ids, type_ids)
    return get_published_theme_notifications(locale, author_ids, type_ids)
  end
  def self.for_story_comment(locale)
    return get_emails(TYPES[:story_comment], locale)
  end
  def self.for_video_prossing_errors(locale)
    return get_video_prossing_errors_emails(locale)
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
         emails = x.map{|x| x.email}.join(';')
      end
      return emails
    end
   
    # get the email address of admins
    def self.get_video_prossing_errors_emails(locale)
      emails = []
      if locale
         x = User.select("distinct email")
         .where("users.wants_notifications = 1 and users.notification_language = ? and role = ?", locale, User::ROLES[:admin])
      end

      if x.present?
         emails = x.map{|x| x.email}.join(';')
      end
      return emails
    end
   
   # get notifications for users that want notifications of new stories:
   # - any new story
   # - story in type
   # - story by author
  def self.get_published_theme_notifications(locale, author_ids, type_ids)
    notifications = []
    if locale
      sql = "users.wants_notifications = 1 and users.notification_language = :locale and ((notification_type = :theme_type and (identifier is null "
      if type_ids.present?
        sql << "or identifier in (:type_ids) "
      end
      sql << ")) "
      if author_ids.present?
        sql << " or (notification_type = :follow_type and identifier in (:author_ids))"
      end
      sql << ")"
      
      notifications = includes(:user)
                       .where(sql, 
                          locale: locale, theme_type: TYPES[:published_theme], type_ids: type_ids,
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
       emails = x.map{|x| x.email}.join(';')
    end
    return emails
  end



end
