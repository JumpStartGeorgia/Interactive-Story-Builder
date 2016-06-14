class AddMeydanRowToTemplates < ActiveRecord::Migration
  def up
    Template.create!({name: "meydan", title: "Baku Real", description: "Baku Real - Six kilometers of stories", author: "Mariam Kobuladze", public: 0, default: 0})
  end
  def down
    Template.where(name: "meydan").first.destroy
  end
end
