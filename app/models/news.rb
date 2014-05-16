class News < ActiveRecord::Base

  def self.published
    where(:is_published => true).order('published_at desc, title asc')
  end
end
