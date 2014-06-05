class Language < ActiveRecord::Base

	validates :locale, :presence => true
	validates :name, :presence => true

  has_many :stories, :primary_key => :locale, :foreign_key => :locale

  def self.sorted
    order('name asc')
  end
  
  def self.with_stories
    where('published_story_count > 0')
  end
  
  def self.increment_count(locale)
    where(:locale => locale).update_all('published_story_count = published_story_count + 1')
  end

  def self.decrement_count(locale)
    where(:locale => locale).update_all('published_story_count = if(published_story_count=0, 0, published_story_count - 1)')
  end
end
