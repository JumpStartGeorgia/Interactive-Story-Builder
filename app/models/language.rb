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
=begin
  def self.increment_count(locale)
    where(:locale => locale).update_all('published_story_count = published_story_count + 1')
  end

  def self.decrement_count(locale)
    where(:locale => locale).update_all('published_story_count = if(published_story_count=0, 0, published_story_count - 1)')
  end
=end
  # special format of name (#) for filter list
  def name_count
    "#{self.name} (#{self.published_story_count})"
  end
  
  
  # update the counts of languages with published stories
  def self.update_counts
    sql = "select locale, count(*) as count from stories where published = 1 group by locale order by locale"

    counts = find_by_sql(sql)

    Language.transaction do 
      # reset all counts to 0
      Language.update_all(:published_story_count => 0)
  
      if counts.present?
        # add the counts
        counts.each do |count|
          Language.where(:locale => count['locale']).update_all(:published_story_count => count['count'])
        end
      end
    end
  end
  
end
