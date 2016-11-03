class PopulateFriendlyIdSlugs < ActiveRecord::Migration
  def up

    # Story translation have same permalink as 554 so we number added at the end
    issue1 = StoryTranslation.find(555)
    issue1.permalink_staging = "#{issue1.permalink_staging} 1"
    issue1.save

    StoryTranslation.find_each(&:save)

  end

  def down
  end
end
