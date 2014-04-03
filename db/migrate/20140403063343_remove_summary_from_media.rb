class RemoveSummaryFromMedia < ActiveRecord::Migration
  def up
    remove_column :media, :summary
  end

  def down
    add_column :media, :summary, :string
  end
end
