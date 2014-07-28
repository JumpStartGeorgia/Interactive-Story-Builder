class NotificationTrigger < ActiveRecord::Base
  attr_accessible :notification_type, :identifier, :processed
  scope :not_processed, where(:processed => false)

  def self.process_all_types
    process_new_user
    process_published_news
    process_published_story
    process_story_collaboration
    process_staff_pick_selection
    process_story_comment
  end

  #################
  ## new user
  #################
  def self.add_new_user(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:new_user], :identifier => id)
  end

  def self.process_new_user
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:new_user]).not_processed    
    if triggers.present?
      I18n.available_locales.each do |locale|          
        message = Message.new
        message.bcc = Notification.for_new_user(locale,triggers.map{|x| x.identifier}.uniq)
        if message.bcc.present?
          message.locale = locale
          message.subject = I18n.t("mailer.notification.new_user.subject", :locale => locale)
          message.message = I18n.t("mailer.notification.new_user.message", :locale => locale)                  
          NotificationMailer.send_new_user(message).deliver
        end
      end
      NotificationTrigger.where(:id => triggers.map{|x| x.id}).update_all(:processed => true)
    end
  end

  #################
  ## published news
  #################
  def self.add_published_news(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:published_news], :identifier => id)
  end

  def self.process_published_news
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:published_news]).not_processed    
    if triggers.present?
      orig_locale = I18n.locale
      I18n.available_locales.each do |locale|          
        I18n.locale = locale
        message = Message.new
        message.bcc = Notification.for_published_news(locale)
        if message.bcc.present?
          message.locale = locale
          message.subject = I18n.t("mailer.notification.published_news.subject", :locale => locale)
          message.message = I18n.t("mailer.notification.published_news.message", :locale => locale)                  
          message.message_list = []

          triggers.map{|x| x.identifier}.uniq.each do |id|
            news = News.published.find_by_id(id)
            if news.present?
              message.message_list << [news.title, news.permalink]
		        end
	        end
          NotificationMailer.send_published_news(message).deliver
        end
      end
      NotificationTrigger.where(:id => triggers.map{|x| x.id}).update_all(:processed => true)

      # reset the locale      
      I18n.locale = orig_locale
    end
  end

  #################
  ## published story
  #################
  def self.add_published_story(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:published_story], :identifier => id)
  end

  # published story can trigger the following notifications
  # - follow new stories
  # - follow new stories in a category
  # - follow new stories by a user
  # - staff pick review
  # for the following triggers, create custom email for each user that wants notification
  def self.process_published_story
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:published_story]).not_processed    
    if triggers.present?
      # get stories for these triggers
      stories = Story.is_published.recent.where(:id => triggers.map{|x| x.identifier}.uniq)
      if stories.present?
        # send staff pick review notification
        process_staff_pick_review(triggers, stories)

        # get the author ids and category ids for the stories
        # so can pull in list of users that want notifications for one of these
        author_ids = stories.map{|x| [x.id,x.user_id]}
        uniq_author_ids = author_ids.map{|x| x[1]}.uniq if author_ids.present?      
        category_ids = stories.map{|x| [x.id, x.story_categories.map{|y| y.category_id}]} 
        uniq_category_ids = category_ids.map{|x| x[1]}.flatten.uniq if category_ids.present?      
        
        orig_locale = I18n.locale
        I18n.available_locales.each do |locale|          
          I18n.locale = locale

          # get users that want one of the following:
          # - new story notification
          # - new story in category notification
          # - new story by author
          notifications = Notification.for_published_story(locale, uniq_author_ids, uniq_category_ids)
          if notifications.present?
            # get unique user_ids
            user_ids = notifications.map{|x| x.user_id}.uniq
            user_ids.each do |user_id|
              email = notifications.select{|x| x.user_id == user_id}.map{|x| x.user.email}.uniq.first

              # get the notifications for this user
              user_notifications = notifications.select{|x| x.user_id == user_id}
              # if this user wants notifications for all stories, send them all
              # else, get the stories that this user cares about
              stories_to_send = []
              if user_notifications.index{|x| x.notification_type == Notification::TYPES[:published_story] && x.identifier.nil?}.present?
                # all stories
                stories_to_send = stories
              else
                # filter by category and/or author
                story_ids = []

                # by category
                category_notifications = user_notifications.select{|x| x.notification_type == Notification::TYPES[:published_story] && x.identifier.present?}
                if category_notifications.present?
                  category_notifications_ids = category_notifications.map{|x| x.identifier}
                  category_notifications_ids.each do |cat_not_id|
                    story_ids << category_ids.select{|x| x[1].include?(cat_not_id)}.map{|x| x[0]}
                  end
                end
                
                # by author
                author_notifications = user_notifications.select{|x| x.notification_type == Notification::TYPES[:published_story_by_author] && x.identifier.present?}
                if author_notifications.present?
                  author_notifications_ids = author_notifications.map{|x| x.identifier}
                  author_notifications_ids.each do |aut_not_id|
                    story_ids << author_ids.select{|x| x[1] == aut_not_id}.map{|x| x[0]}
                  end
                end
                
                story_ids.flatten!.uniq!
                stories_to_send = stories.select{|x| story_ids.include?(x.id)}
              end
            
              # if stories found, send notification
              if stories_to_send.present?
                message = Message.new
                message.email = email
                message.locale = locale
                message.subject = I18n.t("mailer.notification.published_story.subject", :locale => locale)
                message.message = I18n.t("mailer.notification.published_story.message", :locale => locale)                  
                message.message_list = []

                stories_to_send.each do |story|
                  message.message_list << [story.title, story.permalink]
                end
                NotificationMailer.send_published_story(message).deliver
              end
            end
          end
        end
        # reset the locale      
        I18n.locale = orig_locale
      end
      NotificationTrigger.where(:id => triggers.map{|x| x.id}).update_all(:processed => true)
    end
  end

  #################
  ## staff pick selection
  #################
  def self.add_staff_pick_selection(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:staff_pick_selection], :identifier => id)
  end

  def self.process_staff_pick_selection
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:staff_pick_selection]).not_processed    
    if triggers.present?
      # get stories for these triggers
      stories = Story.is_published.recent.where(:id => triggers.map{|x| x.identifier}.uniq)
      if stories.present?
        author_ids = stories.map{|x| x.user_id}.uniq
        
        orig_locale = I18n.locale
        author_ids.each do |author_id|
          user = User.find_by_id(author_id)
          if user.present?
            I18n.locale = user.notification_language.to_sym
            message = Message.new
            message.email = user.email
            message.locale = I18n.locale
            message.subject = I18n.t("mailer.notification.staff_pick_selection.subject", :locale => I18n.locale)
            message.message = I18n.t("mailer.notification.staff_pick_selection.message", :locale => I18n.locale)                  
            message.message_list = []

            stories.select{|x| x.user_id == author_id}.each do |story|
              message.message_list << [story.title, story.permalink]
            end
            NotificationMailer.send_staff_pick_selection(message).deliver
          end
        end
        # reset the locale      
        I18n.locale = orig_locale
      end
      NotificationTrigger.where(:id => triggers.map{|x| x.id}).update_all(:processed => true)
    end
  end

  #################
  ## story comment
  #################
  def self.add_story_comment(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:story_comment], :identifier => id)
  end

  def self.process_story_comment
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:story_comment]).not_processed    
    if triggers.present?
      # get stories for these triggers
      stories = Story.is_published.recent.where(:id => triggers.map{|x| x.identifier}.uniq)
      if stories.present?
        author_ids = stories.map{|x| x.user_id}.uniq
        
        orig_locale = I18n.locale
        author_ids.each do |author_id|
          user = User.find_by_id(author_id)
          if user.present?
            I18n.locale = user.notification_language.to_sym
            message = Message.new
            message.email = user.email
            message.locale = I18n.locale
            message.subject = I18n.t("mailer.notification.story_comment.subject", :locale => I18n.locale)
            message.message = I18n.t("mailer.notification.story_comment.message", :locale => I18n.locale)                  
            message.message_list = []

            stories.select{|x| x.user_id == author_id}.each do |story|
              comment_num = triggers.select{|x| x.identifier == story.id}.length
              comment_text = ''
              if comment_num > 1
                comment_text = I18n.t("mailer.notification.story_comment.comments", :locale => I18n.locale, :num => comment_num)
              elsif comment_num == 1
                comment_text = I18n.t("mailer.notification.story_comment.comment", :locale => I18n.locale)
              end
              message.message_list << [story.title, story.permalink, comment_text]
            end
            NotificationMailer.send_story_comment(message).deliver
          end
        end
        # reset the locale      
        I18n.locale = orig_locale
      end
      NotificationTrigger.where(:id => triggers.map{|x| x.id}).update_all(:processed => true)
    end
  end



  #################
  ## story collaboration
  #################
  def self.add_story_collaboration(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:story_collaboration], :identifier => id)
  end

  # slightly different format
  # for invitations that need triggers, get uniq list of emails
  # and then for each email send an invitation
  # - this way if user has > 1 invitation they will all be in one email
  def self.process_story_collaboration
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:story_collaboration]).not_processed    
    if triggers.present?
      invitations = Invitation.where(:id => triggers.map{|x| x.identifier}.uniq)
      if invitations.present?
        emails = invitations.map{|x| x.to_email}.uniq
        if emails.present?
          orig_locale = I18n.locale
          emails.each do |email|
            invs = invitations.select{|x| x.to_email == email}
            if invs.present?
              # if invitations have user_id, get language
              # else, use default language
              I18n.locale = I18n.default_locale
              user_ids = invs.map{|x| x.to_user_id}.uniq
              if !(user_ids.include?(nil) && user_ids.length == 1)
                # has user id
                I18n.locale = User.get_notification_language_locale(user_ids.select{|x| x.present?}.first)
              end
            
              message = Message.new
              message.email  = email
              message.locale = I18n.locale
              message.subject = I18n.t("mailer.notification.story_collaboration.subject", :locale => I18n.locale)
              message.message = I18n.t("mailer.notification.story_collaboration.message", :locale => I18n.locale)                  
              message.message_list = []

              invs.each do |inv|
                story = Story.select('title').where(:id => inv.story_id).first
                if story.present?
                  message.message_list << [inv.from_user.nickname, story.title, inv.key, inv.message]
		            end
	            end
              NotificationMailer.send_story_collaboration(message).deliver
            end
          end

          # reset the locale      
          I18n.locale = orig_locale
        end
      end
      NotificationTrigger.where(:id => triggers.map{|x| x.id}).update_all(:processed => true)
    end
  end
  
  #################
  ## processed videos
  #################
  # if there are any items in /script/video_processing/processed.csv
  # update the asset processed flag, record trigger and send
  def self.process_processed_videos
    require 'csv'
    
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    queue_file = "#{Rails.root}/script/video_processing/processed.csv"
    new_file = "#{Rails.root}/script/video_processing/process_triggers.csv"
    orig_locale = I18n.locale

    # if file does not exist, stop
    if File.exists? queue_file
      puts "$$$$$$$$$$$$$$$$ files exists!"
      # move file to new name so any current processing can continue
      FileUtils.mv queue_file, new_file
      
      # read in the contents of the file
      videos = []
      CSV.parse(File.new(new_file)) do |row|
        if row.present?
          videos << row
        end
      end

      puts "$$$$$$$$$$$$$$$$ videos = #{videos}"
      
      if videos.present?
        Asset.transaction do
          # mark assets as processed
          puts "$$$$$$$$$$$$$$$$ - marking as processed"
          asset_ids = videos.map{|x| x[1]}.uniq
          Asset.where(:id => asset_ids).update_all(:processed => true)

          # create notification for each user
          # - notification email has all stories in one email
          # - trigger is created at end
          story_ids = videos.map{|x| x[0]}.uniq
          puts "$$$$$$$$$$$$$$$$ - story ids = #{story_ids}"
          stories = Story.where(:id => story_ids)
          if stories.present?
            puts "$$$$$$$$$$$$$$$$ - found stories!"
            user_ids = stories.map{|x| x.user_id}.uniq
            if user_ids.present?
              puts "$$$$$$$$$$$$$$$$ - story ids = #{user_ids}"
              user_ids.each do |user_id|
                user = User.find_by_id(user_id)
                if user.present?
                  user_stories = stories.select{|x| x.user_id == user_id}
                  if user_stories.present?
                    I18n.locale = user.notification_language.to_sym
                    message = Message.new
                    message.email = user.email
                    message.locale = I18n.locale
                    message.subject = I18n.t("mailer.notification.processed_videos.subject", :locale => I18n.locale)
                    message.message = I18n.t("mailer.notification.processed_videos.message", :locale => I18n.locale)                  
                    message.message_list = []

                    user_stories.each do |story|
                      # get videos for this story
                      videos = Asset.videos_for_story(story.id)
                      if videos.present?
                        exists_videos = videos.select{|x| x.asset.exists?}
                        if exists_videos.present?
                          total = exists_videos.length
                          processed = exists_videos.select{|x| x.processed == true}.length
                          info = []
                          info << story.title
                          info << story.id
                          info << processed 
                          info << total
                          info << exists_videos.select{|x| x.processed == true}.map{|x| x.asset_file_name}
                          info << exists_videos.select{|x| x.processed == false}.map{|x| x.asset_file_name}
                          message.message_list << info
                        end
                      end
                    end
                    puts "$$$$$$$$$$$$$$$$ - message list = #{message.message_list}"
                    
                    # send the notification to this user
                    NotificationMailer.send_processed_videos(message).deliver if message.message_list.present?

                    # record notifications
                    user_videos = videos.select{|x| user_stories.map{|y| y.id}.include?(x[0])}
                    if user_videos.present?
                      user_videos.each do |user_video|
                        NotificationTrigger.create(:notification_type => Notification[:processed_videos],
                          :identifier => user_video[1],
                          :processed => true
                        )
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
      
      # delete the file
      FileUtils.rm new_file
    end

    # reset the locale      
    I18n.locale = orig_locale
  end  
  
  
protected

  #################
  ## staff pick review
  #################
  def self.process_staff_pick_review(triggers, stories)
    if triggers.present? && stories.present?
      # filter stories that already have staff pick
      # - should not happen, but just in case
      to_review = stories.select{|x| x.staff_pick == false}
    
      orig_locale = I18n.locale
      I18n.available_locales.each do |locale|          
        I18n.locale = locale
        message = Message.new
        message.bcc = Notification.for_staff_pick_review(locale)
        if message.bcc.present?
          message.locale = locale
          message.subject = I18n.t("mailer.notification.staff_pick_review.subject", :locale => locale)
          message.message = I18n.t("mailer.notification.staff_pick_review.message", :locale => locale)                  
          message.message_list = []

          triggers.map{|x| x.identifier}.uniq.each do |id|
            story = to_review.select{|x| x.id == id}.first
            if story.present?
              message.message_list << [story.title, story.permalink]
		        end
	        end
          NotificationMailer.send_staff_pick_review(message).deliver
        end
      end
      # reset the locale      
      I18n.locale = orig_locale
    end
  end

  

end
