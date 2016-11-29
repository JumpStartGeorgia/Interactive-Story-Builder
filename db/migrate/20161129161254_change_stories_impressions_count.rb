class ChangeStoriesImpressionsCount < ActiveRecord::Migration
  def change
    Story.update_all(impressions_count: 0)
    Story.all.map(&:update_impressionist_counter_cache)
  end
end
