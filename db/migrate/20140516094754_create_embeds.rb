class CreateEmbeds < ActiveRecord::Migration
  def change
    create_table :embed_media do |t|
      t.integer :section_id
      t.string :title
      t.string :url
      t.text :code

      t.timestamps
    end
    
    add_index :embed_media, :section_id
  end
end
