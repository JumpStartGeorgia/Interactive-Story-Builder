class UpdatePermalinks < ActiveRecord::Migration
  def up
    News.transaction do 
      puts 'updating news'
      NewsTranslation.update_all(:permalink => nil)
      NewsTranslation.all.each do |nt|
        nt.generate_permalink!
        nt.save
      end
    
      puts 'updating stories'
      Story.update_all(:permalink => nil)
      Story.is_published.each do |s|
        s.generate_permalink!
        s.save
      end
      
      puts 'updating users'
      User.update_all(:permalink => nil)
      User.all.each do |u|
        u.generate_permalink!
        u.save
      end
    
    end
  
  end

  def down
    # do nothing
  end
end
