class AddStoriesCountToThemeTranslation < ActiveRecord::Migration
  def up
    add_column :theme_translations, :stories_count, :integer, :default => 0
    # for all themes and locales get amount of stories in each theme for published stories based on specific locale and update theme.stories_count accordingly
    Theme.all.each{|t|
      I18n.available_locales.each{|l|
        cnt = Theme.select('distinct stories.id').joins(:stories => :story_translations).where('story_translations.published = 1 and story_translations.locale = ? and themes.id = ?', l, t.id).count
        theme_trans = t.translation_for(l)
        theme_trans.update_attribute(:stories_count, cnt) if theme_trans.present?
      }
    }
  end
  def down
    remove_column :theme_translations, :stories_count
  end
end
