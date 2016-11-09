class PopulateFriendlyIdSlugs < ActiveRecord::Migration
  def up

    puts "----------------------- StoryTranslation"
    StoryTranslation.find_each(&:save)
    puts "----------------------- AuthorTranslation"
    AuthorTranslation.find_each(&:save)
    puts "----------------------- CategoryTranslation"
    CategoryTranslation.find_each(&:save)
    puts "----------------------- NewsTranslation"
    NewsTranslation.find_each(&:save)
    puts "----------------------- StoryTypeTranslation"
    StoryTypeTranslation.find_each(&:save)
    puts "----------------------- ThemeTranslation"
    ThemeTranslation.find_each(&:save)
    puts "----------------------- completed"

  end

  def down
  end
end
