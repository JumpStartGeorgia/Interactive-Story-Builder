class AddDynamicDisplay < ActiveRecord::Migration
  def change
    add_column :infographics, :dynamic_render, :integer, :limit => 1, default: 1
  end
end
