class CreateInfographics < ActiveRecord::Migration
  def up
    create_table :infographics do |t|
      t.integer :section_id
      t.date :published_at

      t.timestamps
    end
    add_index :infographics, :section_id

    Infographic.create_translation_table! :title => :string, :caption => :string, :description => :text, :dataset_url => :string

    create_table :infographic_datasources do |t|
      t.integer :infographic_translation_id
      t.string :name
      t.string :url

      t.timestamps
    end
    add_index :infographic_datasources, :infographic_translation_id


  end

  def down
    drop_table :infographics
    Infographic.drop_translation_table!
    drop_table :infographic_datasources
  end
end
