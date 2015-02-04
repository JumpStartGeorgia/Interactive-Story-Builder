class StoryTranslationProgress < ActiveRecord::Base
  belongs_to :story

  attr_accessible :story_id, :locale, :items_completed, :can_publish, :is_story_locale

  validates :story_id, :locale, :presence => true

end
