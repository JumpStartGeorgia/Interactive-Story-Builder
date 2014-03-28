class AddPositionToMedia < ActiveRecord::Migration
  def change
    add_column :media, :position, :integer
  end
end
