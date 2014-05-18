class NewsTranslation < ActiveRecord::Base
	require 'utf8_converter'
  has_permalink :create_permalink, scope: :locale

	belongs_to :news
  attr_accessible :news_id, :title, :content, :locale, :permalink
  # have to create locale variables for this for the news object is not saved before create_permalink is called
	attr_accessor :is_published, :published_at, :title_was

  # if the title changes, make sure the permalink is updated
 	after_find :set_title
  before_save :check_title

  validates :title, :content, :presence => true
    
    
  def required_data_provided?
    provided = false
    
    provided = self.title.present? && self.content.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.title = obj.title if self.title.blank?
    self.content = obj.content if self.content.blank?
  end
  
  def set_title
		self.title_was = self.has_attribute?(:title) ? self.title : nil		
  end
  
  def check_title
    self.generate_permalink! if self.title != self.title_was
  end 
  
  def create_permalink
    date = ''
    if self.news_id.present? && self.published_at.present? && self.is_published?
      date << self.published_at.to_s
      date << '-'
      "#{date}#{Utf8Converter.convert_ka_to_en(self.title.clone.to_ascii.gsub(/[^0-9A-Za-z|_\- ]/,''))}"
    end
  end

  
end
