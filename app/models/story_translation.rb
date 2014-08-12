class StoryTranslation < ActiveRecord::Base
	belongs_to :story

  attr_accessible :shortened_url, :locale

  validates :shortened_url, :presence => true

  def required_data_provided?
    provided = false
    
    provided = self.shortened_url.present?
    
    return provided
  end
  
  def add_required_data(obj)
    self.shortened_url = obj.shortened_url if self.shortened_url.blank?
  end


end
