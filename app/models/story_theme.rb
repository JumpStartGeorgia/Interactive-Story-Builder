class StoryTheme < ActiveRecord::Base
  belongs_to :story
  belongs_to :theme

  attr_accessible :story_id, :theme_id

  #################################
  ## Validations
  validates :story_id, :theme_id, :presence => true


  # code to calculate theme stories count
    after_save :after_save_callback # when new record is added prepare to recalculate
    after_destroy :after_destroy_callback # when old is removed prepare to recalculate
    after_commit :after_commit_callback # only recalculate theme stories_count if commit is called

    def after_save_callback
      @changes = [[self.theme_id], self.story.all_published_locales, 1]
    end
    def after_destroy_callback
      @changes = [[self.theme_id], self.story.all_published_locales, -1]
    end
    def after_commit_callback
      Theme.stories_count_recalculate(@changes) if @changes.present?
    end
  # ---

end
