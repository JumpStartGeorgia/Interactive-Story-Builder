class AddBackgroundColumnToSection < ActiveRecord::Migration
  def up
    add_column :sections, :background, :integer, :default => 0
  end

  def down
    remove_column :sections, :background
  end
end
