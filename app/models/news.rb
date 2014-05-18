class News < ActiveRecord::Base
	translates :title, :content
	
	has_many :news_translations, :dependent => :destroy
  accepts_nested_attributes_for :news_translations
	

  def self.published
    with_translations(I18n.locale).where(:is_published => true).order('news.published_at desc, news_translations.title asc')
  end
end
