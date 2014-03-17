class ChangeColumnNameBack < ActiveRecord::Migration
  def change
		rename_column :sections, :type, :type_id		
	end
end
