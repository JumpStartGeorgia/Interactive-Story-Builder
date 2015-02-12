class AddInfographicType < ActiveRecord::Migration
  def up
    t = StoryType.create(:id => 5, :sort_order => 5)
    t.story_type_translations.create(:locale => 'en', :name => 'Infographic')
    t.story_type_translations.create(:locale => 'ka', :name => 'Infographic')
    t.story_type_translations.create(:locale => 'ru', :name => 'Infographic')
    t.story_type_translations.create(:locale => 'az', :name => 'Infographic')
    t.story_type_translations.create(:locale => 'hy', :name => 'Infographic')
  end

  def down
    StoryType.where(id: 5).destroy_all
  end
end
