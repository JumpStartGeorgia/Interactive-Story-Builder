class NewsTranslation < ActiveRecord::Base
  has_permalink :create_permalink, true

	belongs_to :news
  attr_accessible :news_id, :title, :content, :locale, :permalink
  # have to create locale variables for this for the news object is not saved before create_permalink is called
	attr_accessor :is_published, :published_at

  # if the title changes, make sure the permalink is updated
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
  
  def check_title
    self.generate_permalink! if self.title_changed?
  end 
  
  def create_permalink
    if self.news_id.present? && self.news.published_at.present? && self.news.is_published == true
      date = ''
      date << self.news.published_at.to_s
      date << '-'
      "#{date}#{self.title.dup}"
    end
  end
  
end
