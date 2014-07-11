class Notification < ActiveRecord::Base
  	attr_accessible :identifier, :notification_type, :user_idTYPES = {:new_file => 1, :change_vote => 2, :law_is_public => 3, :new_delegate => 4}
   TYPES = {:account_created => 1, :story_published => 2, :story_commented => 3, :publish_by_leader => 4, :news_added => 5 }

   def for_account_created
      nil
   end
   def for_story_published
      nil
   end
   def for_story_commented
      nil
   end
   def for_publish_by_leader
      nil
   end
   def for_news_added
      nil
   end
   
end
