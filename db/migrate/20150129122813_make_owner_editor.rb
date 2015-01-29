class MakeOwnerEditor < ActiveRecord::Migration
  def up
    # user must have record in storyuser in order to edit story
    # this is a change from past, so update all existing records so owner has record in storyuser
    Story.transaction do
      Story.all.each do |story|
        # if the owner is not alread in story user table, add them
        if story.user_role(story.user_id).blank?
          story.story_users.create(user_id: story.user_id, role: 0)
        end
      end
    end
  end

  def down
    # do nothing
  end
end
