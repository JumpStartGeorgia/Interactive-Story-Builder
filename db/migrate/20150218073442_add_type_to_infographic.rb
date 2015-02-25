class AddTypeToInfographic < ActiveRecord::Migration
  def change
    add_column :infographics, :type, :integer
  end
end
