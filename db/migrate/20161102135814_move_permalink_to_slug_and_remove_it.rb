class MovePermalinkToSlugAndRemoveIt < ActiveRecord::Migration
  def up
    StoryTranslation.transaction do
      StoryTranslation.where("permalink != ?", nil).each {|t|
        t.slug = t.permalink
        t.save!
      }
    end
  end

  def down
    StoryTranslation.where("permalink != ?", nil).each {|t|
      t.slug = nil
      t.save
    }
  end
end
