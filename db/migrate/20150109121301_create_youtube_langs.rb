class CreateYoutubeLangs < ActiveRecord::Migration
  def change
    create_table :youtube_langs do |t|
      t.integer :youtube_id
      t.string :lang, :default => 'en'
      t.string :menu_lang, :default => 'en'
      t.string :cc_lang, :default => 'en' 
      t.text :code

      t.timestamps
    end
    add_index :youtube_langs, [:youtube_id,:lang], :name => "index_youtube_langs_on_youtube_id_and_lang"
  end
end
