class CreateNews < ActiveRecord::Migration
  def change
    create_table :news do |t|
      t.string :title
      t.text :content
      t.boolean :is_published, :default => false
      t.date :published_at

      t.timestamps
    end
    
    add_index :news, [:is_published, :published_at, :title]
  end
end
