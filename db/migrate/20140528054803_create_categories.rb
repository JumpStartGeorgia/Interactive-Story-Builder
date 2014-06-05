class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.timestamps
    end

		Category.create_translation_table! :name => :string, :permalink => :string

		add_index :category_translations, :name
		add_index :category_translations, :permalink
  end

	def self.down
		Category.drop_translation_table!
		drop_table :categories
	end
end
