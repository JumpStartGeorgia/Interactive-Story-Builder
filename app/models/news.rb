class News < ActiveRecord::Base
	translates :title, :content, :permalink
	
	has_many :news_translations, :dependent => :destroy
  accepts_nested_attributes_for :news_translations
  
	attr_accessor :was_published, :was_published_at

 	after_find :set_published
 	before_validation :check_if_published
	
	def set_published
		self.was_published = self.has_attribute?(:is_published) ? self.is_published : nil		
		self.was_published_at = self.has_attribute?(:published_at) ? self.published_at : nil		
	end
	
	
	def check_if_published
	  if (self.was_published != self.is_published && self.is_published) || (self.was_published_at != self.published_at && self.published_at.present?)
	    self.news_translations.each{|nt| nt.generate_permalink!}
	  end
	end

  def self.published
    with_translations(I18n.locale).where(:is_published => true).order('news.published_at desc, news_translations.title asc')
  end
end
