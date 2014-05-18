class CreateNews < ActiveRecord::Migration
  def up
    create_table :news do |t|
      t.boolean :is_published, :default => false
      t.date :published_at

      t.timestamps
    end
    
    News.create_translation_table! :title => :string, :content => :text
    
    add_index :news, [:is_published, :published_at]
    add_index :news_translations, :title

  end
  
  def down
    drop_table :news
    News.drop_translation_table!
  end
end
