class News < ActiveRecord::Base
	translates :title, :content, :permalink
	
	has_many :news_translations, :dependent => :destroy
  accepts_nested_attributes_for :news_translations
  
	attr_accessor :send_notification

  after_save :check_if_published
	
	def check_if_published
    if self.is_published_changed? && self.is_published == true && self.published_at.present?
	    self.news_translations.each do |nt| 
	      nt.generate_permalink!
	      nt.save
      end
	  end
	end

  # allow locale to be passed in for sending notifications about news
  def self.published(locale = I18n.locale)
    with_translations(locale).where(:is_published => true).order('news.published_at desc, news_translations.title asc')
  end
end
