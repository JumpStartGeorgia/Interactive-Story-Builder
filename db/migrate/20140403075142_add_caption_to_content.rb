class AddCaptionToContent < ActiveRecord::Migration
  def change
    add_column :contents, :caption, :string, :limit => 255
  end
end
