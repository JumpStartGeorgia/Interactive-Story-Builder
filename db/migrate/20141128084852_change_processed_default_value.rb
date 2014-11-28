class ChangeProcessedDefaultValue < ActiveRecord::Migration
  def up
    change_column :assets, :processed, :boolean, :default => false
  end

  def down
    change_column :assets, :processed, :boolean, :default => true
  end
end
