class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :name
      t.string :title
      t.text :description
      t.string :author
      t.text :params
      t.boolean :default

      t.timestamps
    end
  end
end
