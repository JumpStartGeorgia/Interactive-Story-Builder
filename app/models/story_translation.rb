class StoryTranslation < ActiveRecord::Base
	belongs_to :story

  has_permalink :create_permalink, true

  attr_accessible :shortened_url, :title, :permalink, :permalink_staging, :author, :media_author, :about, :locale

  #################################
  ## Validations
  validates :title, :presence => true, length: { maximum: 100 }
  validates :author, :presence => true, length: { maximum: 255 }
  validates :permalink, :presence => true
  validates :media_author, length: { maximum: 255 }
  #validates :shortened_url, :presence => true

  # def required_data_provided?
  #   provided = false
    
  #   provided = self.shortened_url.present?
    
  #   return provided
  # end
  
  # def add_required_data(obj)
  #   self.shortened_url = obj.shortened_url if self.shortened_url.blank?
  # end

  def create_permalink
    if self.permalink_staging.present? && self.permalink_staging != self.permalink
      self.permalink_staging.dup
    else
      self.title.dup
    end
  end


  #################################
  # settings to clone story
  amoeba do
    enable

    # update the title
    append :title => " (Clone)"

    # reset some fields
    nullify :permalink
    nullify :permalink_staging

  end
end
