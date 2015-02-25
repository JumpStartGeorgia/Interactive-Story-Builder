class AddFeatureStories < ActiveRecord::Migration
  def up
    rename_column :stories, :in_theme_slider, :old_in_theme_slider

    ThemeFeature.transaction do
      ThemeFeature.destroy_all

      disabled = ['The Hard Life Of Denis', 'Dreaming in the Darkness', 'Chai Khana Talk Show with UNDP', 'Challenges of Being Disabled in the South Caucasus']
      theme_id = 1
      disabled.each_with_index do |title, index|
        trans = StoryTranslation.find_by_title(title)
        if trans.present?
          ThemeFeature.create(theme_id: theme_id, story_id: trans.story_id, position: index+1)
        end
      end

      minority = ['One Life - Different Countries', '30 Families of Griz', 'Lezgins - A Prominent Ethnic Group In Azerbaijan', 'Tsopi']
      theme_id = 2
      minority.each_with_index do |title, index|
        trans = StoryTranslation.find_by_title(title)
        if trans.present?
          ThemeFeature.create(theme_id: theme_id, story_id: trans.story_id, position: index+1)
        end
      end

    end
  end

  def down
    rename_column :stories, :old_in_theme_slider, :in_theme_slider

    ThemeFeature.destroy_all
  end
end
