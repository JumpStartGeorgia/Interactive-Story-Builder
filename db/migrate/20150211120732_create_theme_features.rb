class CreateThemeFeatures < ActiveRecord::Migration
  def change
    create_table :theme_features do |t|
      t.integer :theme_id
      t.integer :story_id
      t.integer :position

      t.timestamps
    end

    add_index :theme_features, [:theme_id, :position]
    add_index :theme_features, [:story_id, :position]
    add_index :theme_features, :position
  end
end
