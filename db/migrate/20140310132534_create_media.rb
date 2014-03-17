class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.integer :section_id
      t.integer :media_type
      t.string :title
      t.string :caption
      t.integer :caption_align
      t.string :summary
      t.string :source
      t.string :audio_path
      t.string :video_path

      t.timestamps
    end
  end
end
