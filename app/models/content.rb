class Content < ActiveRecord::Base
	belongs_to :section	

	validates :section_id, :presence => {:message => 'Content is out of section.'}	
	validates :title, :presence => {:message => ' is missing'}, length: { maximum: 255, :message => 'Title max length is 255 symbols' } 	
	validates :subtitle, :presence => {:message => ' is missing'}, length: { maximum: 255, :message => 'Subtitle max length is 255 symbols' } 	
	validates :content, :presence => {:message => ' is missing'} 	
	
	def to_json(options={})
     options[:except] ||= [:created_at, :updated_at]
     super(options)
   end
end
