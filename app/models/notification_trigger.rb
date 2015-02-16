class NotificationTrigger < ActiveRecord::Base
  attr_accessible :notification_type, :identifier, :processed
  scope :not_processed, where(:processed => false)

  def self.process_all_types
    puts "**************************"
    puts "--> Notification Triggers - process all types start at #{Time.now}"
    puts "**************************"
    process_new_user
    process_published_theme
    process_story_collaboration
    process_story_comment
    puts "**************************"
    puts "--> Notification Triggers - process all types end at #{Time.now}"
    puts "**************************"
  end

  #################
  ## new user
  #################
  def self.add_new_user(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:new_user], :identifier => id)
  end

  def self.process_new_user
    puts "--> Notification Triggers - process new users"
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:new_user]).not_processed    
    if triggers.present?
      I18n.available_locales.each do |locale|          
        message = Message.new
        message.bcc = Notification.for_new_user(locale,triggers.map{|x| x.identifier}.uniq)
        if message.bcc.present?
          message.locale = locale
          message.subject = I18n.t("mailer.notification.new_user.subject", :locale => locale)
          message.message = I18n.t("mailer.notification.new_user.message", :locale => locale)                  
          puts " ---> message: #{message.inspect}"
          NotificationMailer.send_new_user(message).deliver if !Rails.env.staging?
        end
      end
      NotificationTrigger.where(:id => triggers.map{|x| x.id}).update_all(:processed => true)
    end
  end

  #################
  ## published theme
  #################
  def self.add_published_theme(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:published_theme], :identifier => id)
  end

  # published theme can trigger the following notifications
  # - follow new themes
  # - follow new stories in a type
  # - follow new stories by a author
  # for the following triggers, create custom email for each user that wants notification
  def self.process_published_theme
    puts "--> Notification Triggers - process published theme"
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:published_theme]).not_processed    
    if triggers.present?
      # get themes for these triggers
      themes = Theme.published.where(:id => triggers.map{|x| x.identifier}.uniq)
      if themes.present?
        # get stories for these triggers
        stories = Story.is_published.in_published_theme.recent.joins(:themes).where(:themes => {:id => themes.map{|x| x.id}})
        if stories.present?
          # get the author ids and type ids for the stories
          # so can pull in list of users that want notifications for one of these
          author_ids = stories.map{|x| [x.id,x.author_ids]}
          uniq_author_ids = author_ids.map{|x| x[1]}.flatten.uniq if author_ids.present?      
          type_ids = stories.map{|x| [x.id, x.story_type_id]} 
          uniq_type_ids = type_ids.map{|x| x[1]}.flatten.uniq if type_ids.present?      
          
          orig_locale = I18n.locale
          I18n.available_locales.each do |locale|          
            I18n.locale = locale

            # get users that want one of the following:
            # - new theme notification
            # - new story in type notification
            # - new story by author
            notifications = Notification.for_published_theme(locale, uniq_author_ids, uniq_type_ids)
            if notifications.present?
              # get unique user_ids
              user_ids = notifications.map{|x| x.user_id}.uniq
              user_ids.each do |user_id|
                email = notifications.select{|x| x.user_id == user_id}.map{|x| x.user.email}.uniq.first

                # get the notifications for this user
                user_notifications = notifications.select{|x| x.user_id == user_id}
                # if this user wants notifications for all themes, send them all
                # else, get the stories that this user cares about
                stories_to_send = []
                themes_to_send = []
                if user_notifications.index{|x| x.notification_type == Notification::TYPES[:published_theme] && x.identifier.nil?}.present?
                  # all themes
                  themes_to_send = themes
                else
                  # filter by type and/or author
                  story_ids = []

                  # by type
                  type_notifications = user_notifications.select{|x| x.notification_type == Notification::TYPES[:published_theme] && x.identifier.present?}
                  if type_notifications.present?
                    type_notifications_ids = type_notifications.map{|x| x.identifier}
                    type_notifications_ids.each do |type_id|
                      story_ids << type_ids.select{|x| x[1] == type_id}.map{|x| x[0]}
                    end
                  end
                  
                  # by author
                  author_notifications = user_notifications.select{|x| x.notification_type == Notification::TYPES[:published_story_by_author] && x.identifier.present?}
                  if author_notifications.present?
                    author_notifications_ids = author_notifications.map{|x| x.identifier}
                    author_notifications_ids.each do |author_id|
                      story_ids << author_ids.select{|x| x[1] == author_id}.map{|x| x[0]}
                    end
                  end
                  
                  story_ids.flatten!.uniq!
                  stories_to_send = stories.select{|x| story_ids.include?(x.id)}
                end
              
                # if themes found, send notification
                if themes_to_send.present?
                  message = Message.new
                  message.email = email
                  message.locale = locale
                  message.subject = I18n.t("mailer.notification.published_theme.subject", :locale => locale)
                  message.message = I18n.t("mailer.notification.published_theme.message", :locale => locale)                  
                  message.message_list = []

                  themes_to_send.each do |theme|
                    message.message_list << [theme.formatted_name, theme.permalink]
                  end
                  puts " ---> message: #{message.inspect}"
                  NotificationMailer.send_published_theme(message).deliver if !Rails.env.staging?
                
                # if stories found, send notification
                elsif stories_to_send.present?
                  message = Message.new
                  message.email = email
                  message.locale = locale
                  message.subject = I18n.t("mailer.notification.published_story.subject", :locale => locale)
                  message.message = I18n.t("mailer.notification.published_story.message", :locale => locale)                  
                  message.message_list = []

                  stories_to_send.each do |story|
                    message.message_list << [story.title, story.permalink]
                  end
                  puts " ---> message: #{message.inspect}"
                  NotificationMailer.send_published_story(message).deliver if !Rails.env.staging?
                end
              end
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
  ## story comment
  #################
  def self.add_story_comment(id)
    NotificationTrigger.create(:notification_type => Notification::TYPES[:story_comment], :identifier => id)
  end

  def self.process_story_comment
    puts "--> Notification Triggers - process story comment"
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:story_comment]).not_processed    
    # if triggers.present?
    #   # get stories for these triggers
    #   stories = Story.is_published.recent.where(:id => triggers.map{|x| x.identifier}.uniq)
    #   if stories.present?
    #     author_ids = stories.map{|x| x.user_id}.uniq
        
    #     orig_locale = I18n.locale
    #     author_ids.each do |author_id|
    #       user = User.find_by_id(author_id)
    #       if user.present?
    #         I18n.locale = user.notification_language.to_sym
    #         message = Message.new
    #         message.email = user.email
    #         message.locale = I18n.locale
    #         message.subject = I18n.t("mailer.notification.story_comment.subject", :locale => I18n.locale)
    #         message.message = I18n.t("mailer.notification.story_comment.message", :locale => I18n.locale)                  
    #         message.message_list = []

    #         stories.select{|x| x.user_id == author_id}.each do |story|
    #           comment_num = triggers.select{|x| x.identifier == story.id}.length
    #           comment_text = ''
    #           if comment_num > 1
    #             comment_text = I18n.t("mailer.notification.story_comment.comments", :locale => I18n.locale, :num => comment_num)
    #           elsif comment_num == 1
    #             comment_text = I18n.t("mailer.notification.story_comment.comment", :locale => I18n.locale)
    #           end
    #           message.message_list << [story.title, story.permalink, comment_text]
    #         end
    #         puts " ---> message: #{message.inspect}"
    #         NotificationMailer.send_story_comment(message).deliver if !Rails.env.staging?
    #       end
    #     end
    #     # reset the locale      
    #     I18n.locale = orig_locale
    #   end
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
    puts "--> Notification Triggers - process story collaboration"
    triggers = NotificationTrigger.where(:notification_type => Notification::TYPES[:story_collaboration]).not_processed    
    if triggers.present?
      invitations = Invitation.where(:id => triggers.map{|x| x.identifier}.uniq)
      if invitations.present?
        emails = invitations.map{|x| x.to_email}.uniq
        if emails.present?
          orig_locale = I18n.locale
          languages = Language.all

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
                story = Story.find_by_id(inv.story_id)
                if story.present?
                  # get the story using the user locale if it exsts
                  story.use_app_locale_if_translation_exists

                  role = inv.role_name
                  # if role is translator, add in the languages for translation
                  if inv.role == Story::ROLE[:translator] && inv.translation_locales.present?
                    role << ' - '
                    locales = inv.translation_locales.split(',')
                    locales.each_with_index do |locale, locale_index|
                      lang = languages.select{|x| x.locale == locale}.first
                      if lang.present?
                        role << lang.name
                        if locale_index < locales.length-1
                          role << ', '
                        end
                      end
                    end
                  end

                  message.message_list << [inv.from_user.nickname, story.title, role, inv.key, inv.message]
		            end
	            end
              puts " ---> message: #{message.inspect}"
              NotificationMailer.send_story_collaboration(message).deliver if !Rails.env.staging?
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
    puts "///////////////////////////"
    puts "--> Notification Triggers - process videos start at #{Time.now}"
    require 'csv'
    
    queue_file = "#{Rails.root}/public/system/video_processing/processed.csv"
    new_file = "#{Rails.root}/public/system/video_processing/process_triggers.csv"
    error_file = "#{Rails.root}/public/system/video_processing/processed_error.csv"
    error_new_file = "#{Rails.root}/public/system/video_processing/processed_error_triggers.csv"
    orig_locale = I18n.locale 

    # if file does not exist, stop
    if File.exists? queue_file
      puts "-- queue files exists!"
      # move file to new name so any current processing can continue
      FileUtils.mv queue_file, new_file
      
      # read in the contents of the file
      videos = []
      CSV.parse(File.new(new_file)) do |row|
        if row.present?
          videos << row
        end
      end

      puts "-- videos = #{videos}"
      
      if videos.present?
        Asset.transaction do
          # mark assets as processed
          puts "-- - marking asset as processed"
          asset_ids = videos.map{|x| x[1]}.uniq
          Asset.where(:id => asset_ids).update_all(:processed => true)

          # # only send notifications if this is production
          # puts "--> env = #{Rails.env}"
          # # create notification for each user
          # # - notification email has all stories in one email
          # # - trigger is created at end
          # story_ids = videos.map{|x| x[0]}.uniq
          # puts "-- - story ids = #{story_ids}"
          # stories = Story.where(:id => story_ids)
          # if stories.present?
          #   puts "-- - found stories!"
          #   user_ids = stories.map{|x| x.user_id}.uniq
          #   if user_ids.present?
          #     puts "-- - story ids = #{user_ids}"
          #     user_ids.each do |user_id|
          #       user = User.find_by_id(user_id)
          #       if user.present?
          #         user_stories = stories.select{|x| x.user_id == user_id}
          #         if user_stories.present?
          #           puts "-- - user stories = #{user_stories}"
          #           I18n.locale = user.notification_language.to_sym
          #           message = Message.new
          #           message.email = user.email
          #           message.locale = I18n.locale
          #           message.subject = I18n.t("mailer.notification.processed_videos.subject", :locale => I18n.locale)
          #           message.message = I18n.t("mailer.notification.processed_videos.message", :locale => I18n.locale)                  
          #           message.message_list = []

          #           user_stories.each do |story|
          #             # get videos for this story
          #             asset_videos = Asset.videos_for_story(story.id)
          #             if asset_videos.present?
          #               exists_videos = asset_videos.select{|x| x.file.exists?}
          #               if exists_videos.present?
          #                 total = exists_videos.length
          #                 processed = exists_videos.select{|x| x.processed == true}.length
          #                 info = []
          #                 info << story.title
          #                 info << story.id
          #                 info << processed 
          #                 info << total
          #                 info << exists_videos.select{|x| x.processed == true}.map{|x| x.asset_file_name}
          #                 info << exists_videos.select{|x| x.processed == false}.map{|x| x.asset_file_name}
          #                 message.message_list << info
          #               end
          #             end
          #           end
          #           puts "-- - message list = #{message.message_list}"
                    
          #           # send the notification to this user
          #           puts " ---> message: #{message.inspect}"
          #           NotificationMailer.send_processed_videos(message).deliver if message.message_list.present? && !Rails.env.staging?

          #           # record notifications
          #           user_videos = videos.select{|x| user_stories.map{|y| y.id.to_s}.include?(x[0].to_s)}
          #           if user_videos.present?
          #             puts " --> creating trigger record"
          #             user_videos.each do |user_video|
          #               NotificationTrigger.create(:notification_type => Notification::TYPES[:processed_videos],
          #                 :identifier => user_video[1],
          #                 :processed => true
          #               )
          #             end
          #           end
          #         end
          #       end
          #     end
          #   end
          # end
        end
      end
      
      # delete the file
      FileUtils.rm new_file
    end
    
    # if the error file exists and has content, send notification
    if File.exists? error_file
      puts "--------------------"
      puts "-- error files exists!"
      # move file to new name so any current processing can continue
      FileUtils.mv error_file, error_new_file
      
      # read in the contents of the file
      videos = []
      CSV.parse(File.new(error_new_file)) do |row|
        if row.present?
          videos << row
        end
      end

      puts "-- videos = #{videos}"
      
      if videos.present?
        puts "-- sending notification"
        I18n.available_locales.each do |locale|          
          I18n.locale = locale
          message = Message.new
          message.bcc = Notification.for_video_prossing_errors(locale)
          if message.bcc.present?
            message.locale = locale
            message.subject = I18n.t("mailer.notification.processed_video_errors.subject", :locale => locale)
            message.message = I18n.t("mailer.notification.processed_video_errors.message", :locale => locale)                  
            message.message_list = []

            videos.each do |video|
              message.message_list << [video[0], video[1], video[2]]
	          end
            puts " ---> message: #{message.inspect}"
            NotificationMailer.send_processed_video_errors(message).deliver if !Rails.env.staging?
          end
        end
      end
      # delete the file
      FileUtils.rm error_new_file
    end
    
    # reset the locale      
    I18n.locale = orig_locale
    puts "--> Notification Triggers - process videos end at #{Time.now}"
    puts "///////////////////////////"
  end  
  
  
end
