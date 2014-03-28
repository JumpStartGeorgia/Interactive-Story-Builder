class RenameSortOrderToPosition < ActiveRecord::Migration
def change
	rename_column :sections, :sort_order, :position
end
end
