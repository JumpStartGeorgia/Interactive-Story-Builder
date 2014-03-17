class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.string :title
      t.integer :user_id
      t.string :author

      t.timestamps
    end
  end
end
