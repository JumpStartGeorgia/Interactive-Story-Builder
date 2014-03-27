class Content < ActiveRecord::Base
	belongs_to :section	

	validates :section_id, :presence => true
	validates :title, :presence => true, length: { maximum: 255 } 	
	validates :subtitle, :presence => true, length: { maximum: 255} 	
	validates :content, :presence => true 	
	
	def to_json(options={})
     options[:except] ||= [:created_at, :updated_at]
     super(options)
   end
end
