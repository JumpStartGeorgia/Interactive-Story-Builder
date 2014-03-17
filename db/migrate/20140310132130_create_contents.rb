class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.integer :section_id
      t.string :title
      t.string :subtitle
      t.string :content

      t.timestamps
    end
  end
end
