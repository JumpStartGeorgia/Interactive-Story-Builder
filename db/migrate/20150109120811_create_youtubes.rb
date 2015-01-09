class CreateYoutubes < ActiveRecord::Migration
  def change
    create_table :youtubes do |t|
      t.integer :section_id
      t.string :title
      t.string :url
      t.integer :video_settings_id

      t.timestamps
    end
    add_index :youtubes, [:section_id], :name => "index_youtubes_on_section_id"
  end
end