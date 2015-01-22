  class Language < ActiveRecord::Base

	validates :locale, :presence => true
	validates :name, :presence => true

  has_many :stories, :primary_key => :locale, :foreign_key => :story_locale
#  default_scope { where(locale:['az','en','hy','ka','ru']) }

  def self.sorted
    order('name asc')
  end
  
  # sort with the app locales first
  def self.app_locale_sorted
    langs = order('name asc')
    
    if langs.present?
      # get app locales
      locales = I18n.available_locales.dup
      temp = []

      # move these locales to the top of the list
      locales.each do |locale|
        index = langs.index{|x| x.locale == locale.to_s}
        if index.present? && index > 0
          temp << langs[index]
          langs.delete_at(index)
        end
      end

      if temp.present?
        temp.sort_by!{|x| x.name}
        langs.to_a.insert(0, temp).flatten!
      end
    end

    return langs
  end


  def self.with_stories
    where(:has_published_stories => true)
  end


=begin
  def self.increment_count(locale)
    where(:locale => locale).update_all('published_story_count = published_story_count + 1')
  end

  def self.decrement_count(locale)
    where(:locale => locale).update_all('published_story_count = if(published_story_count=0, 0, published_story_count - 1)')
  end
=end

=begin  
  # special format of name (#) for filter list
  def name_count
    "#{self.name} (#{self.published_story_count})"
  end
  
  # update the counts of languages with published stories
  def self.update_counts
    sql = "select story_locale, count(*) as count from stories where published = 1 group by story_locale order by story_locale"

    counts = find_by_sql(sql)

    Language.transaction do 
      # reset all counts to 0
      Language.update_all(:published_story_count => 0)
  
      if counts.present?
        # add the counts
        counts.each do |count|
          Language.where(:locale => count['story_locale']).update_all(:published_story_count => count['count'])
        end
      end
    end
  end
=end

  # update the flags for languages with published stories
  def self.update_published_stories_flags
    # get locales with published stories
    locales = Story.published_locales
    
    # update the flag values
    if locales.present?
      sql = "update languages set has_published_stories = if(locale in ("
      sql << locales.map{|x| "'#{x}'"}.join(', ')
      sql << "), 1, 0)"
      
      connection.update(sql)
    else
      update_all(:has_published_stories => 0)
    end
  end  
end
