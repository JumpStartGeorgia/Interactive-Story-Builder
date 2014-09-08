class Category < ActiveRecord::Base
	translates :name, :permalink

	has_many :story_categories, :dependent => :destroy
	has_many :stories, :through => :story_categories
	has_many :category_translations, :dependent => :destroy
  accepts_nested_attributes_for :category_translations

  attr_accessible :id, :category_translations_attributes, :published_story_count

	def self.sorted
		with_translations(I18n.locale).order("category_translations.name asc")
	end

  def self.with_stories
    where('published_story_count > 0')
  end
=begin
  def self.increment_count(id)
    where(:id => id).update_all('published_story_count = published_story_count + 1')
  end

  def self.decrement_count(id)
    where(:id => id).update_all('published_story_count = if(published_story_count=0, 0, published_story_count - 1)')
  end
=end

=begin
  # special format of name (#) for filter list
  def name_count
    "#{self.name} (#{self.published_story_count})"
  end

  # update the counts of categories with published stories
  def self.update_counts
    sql = "select sc.category_id, count(*) as count from story_categories as sc inner join stories as s on s.id = sc.story_id where s.published = 1 group by sc.category_id order by sc.category_id"

    counts = find_by_sql(sql)

    Category.transaction do 
      # reset all counts to 0
      Category.update_all(:published_story_count => 0)
  
      if counts.present?
        # add the counts
        counts.each do |count|
          Category.where(:id => count['category_id']).update_all(:published_story_count => count['count'])
        end
      end
    end
  end
=end

  # update the flags for categories with published stories
  def self.update_published_stories_flags
    # get categories with published stories
    categories = Story.published_categories
    
    # update the flag values
    if categories.present?
      sql = "update categories set has_published_stories = if(id in ("
      sql << categories.map{|x| "'#{x}'"}.join(', ')
      sql << "), 1, 0)"
      
      connection.update(sql)
    else
      update_all(:has_published_stories => 0)
    end
  end  
  
  
end
