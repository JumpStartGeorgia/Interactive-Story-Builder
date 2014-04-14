class ChangeHasMarkerFormatInSections < ActiveRecord::Migration
	def self.up
   		change_column :sections, :has_marker, :boolean
  	end

  	def self.down
   		change_column :sections, :has_marker, :integer
  	end
end
