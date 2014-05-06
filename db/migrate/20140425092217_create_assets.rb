class CreateAssets < ActiveRecord::Migration
  def change
    create_table "assets", :force => true do |t|
      t.integer  "section_id"
      t.integer  "section_type"
      t.string   "caption",            :limit => 45
      t.string   "source",             :limit => 45
      t.integer  "option"
      t.string   "asset_file_name"
      t.string   "asset_content_type", :limit => 45
      t.integer  "asset_file_size"
      t.datetime "asset_updated_at"
      t.integer  "position"
    end

  end
end
