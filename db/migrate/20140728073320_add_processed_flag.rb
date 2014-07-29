class AddProcessedFlag < ActiveRecord::Migration
  def change
    add_column :assets, :processed, :boolean, :default => true
    add_index :assets, :processed 
  end
end
