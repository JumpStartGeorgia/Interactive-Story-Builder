class Language < ActiveRecord::Base

	validates :locale, :presence => true
	validates :name, :presence => true

  has_many :stories, :primary_key => :locale, :foreign_key => :locale

  def self.sorted
    order('name asc')
  end
end
