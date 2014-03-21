class AddHasMarkerToSection < ActiveRecord::Migration
  def change
    add_column :sections, :has_marker, :integer
  end
end
