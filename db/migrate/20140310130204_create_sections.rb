class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.integer :story_id
      t.integer :type_id
      t.string :title
      t.integer :sort_order
      t.string :audio

      t.timestamps
    end
  end
end
