class CreateSlideshows < ActiveRecord::Migration
  def change
    create_table :slideshows do |t|
      t.integer :section_id
      t.string :title
      t.string :caption

      t.timestamps
    end
  end
end
