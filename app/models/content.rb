class Content < ActiveRecord::Base
	belongs_to :section	

	def to_json(options={})
     options[:except] ||= [:created_at, :updated_at]
     super(options)
   end
end
