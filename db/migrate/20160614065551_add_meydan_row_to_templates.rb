class AddMeydanRowToTemplates < ActiveRecord::Migration
  def up
    Template.create!({id: 4, name: "meydan-formula", title: "Baku Real", description: "Baku Real - Six kilometers of stories", author: "Mariam Kobuladze", public: 0, default: 0})
  end
  def down
    Template.where(id: 4).first.destroy
  end
end
