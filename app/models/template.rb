class Template < ActiveRecord::Base
	has_many :stories
	def self.select_list
		select("id, title").order("title asc")
	end
end
