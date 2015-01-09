class CreateVideoSettings < ActiveRecord::Migration
  def change
    create_table :video_settings do |t|
      t.boolean :fullscreen, :default => false
      t.boolean :loop, :default => false
      t.string :lang, :default => 'en'
      t.boolean :cc, :default => true
      t.string :cc_lang, :default => 'en'
      t.boolean :info, :default => false

      t.timestamps
    end
  end
end
