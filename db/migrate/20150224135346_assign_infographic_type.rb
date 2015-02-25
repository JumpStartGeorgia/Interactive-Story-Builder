class AssignInfographicType < ActiveRecord::Migration
  def up
    Infographic.where('subtype is null').update_all(subtype: Infographic::TYPE[:static])
    InfographicTranslation.where('subtype is null').update_all(subtype: Infographic::TYPE[:static])
  end

  def down
    # do nothing
  end
end
