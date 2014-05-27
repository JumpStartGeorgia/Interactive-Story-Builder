class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :locale
      t.string :name

      t.timestamps
    end
    
    add_index :languages, :locale
    add_index :languages, :name
  end
end
