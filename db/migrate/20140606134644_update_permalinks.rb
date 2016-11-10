class UpdatePermalinks < ActiveRecord::Migration
  def up
    News.transaction do
      puts 'updating news'
      NewsTranslation.update_all(:permalink => nil)
      NewsTranslation.find_each(&:save)
      # NewsTranslation.all.each do |nt|
      #   nt.generate_permalink!
      #   nt.save
      # end

      puts 'updating stories'
      StoryTranslation.update_all(:permalink => nil)
      StoryTranslation.find_each(&:save)
      # Story.all.each do |s|
      #   s.generate_permalink!
      #   s.save
      # end

      # puts 'updating users'
      # User.update_all(:permalink => nil)
      # User.all.each do |u|
      #   u.generate_permalink!
      #   u.save
      # end

    end

  end

  def down
    # do nothing
  end
end
