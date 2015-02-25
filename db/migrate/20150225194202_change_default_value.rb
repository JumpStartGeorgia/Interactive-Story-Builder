class ChangeDefaultValue < ActiveRecord::Migration
  def up
    # make default nil
    change_column :infographics, :dynamic_width, :integer, :default => nil, :limit => 2
    change_column :infographics, :dynamic_height, :integer, :default => nil, :limit => 2

    # update any existing records so value of 0 or anything < 200 is nil
    Infographic.transaction do
      Infographic.where('dynamic_width < 200').update_all(:dynamic_width => nil)
      Infographic.where('dynamic_height < 200').update_all(:dynamic_height => nil)
    end
  end

  def down
    # default is 0
    change_column :infographics, :dynamic_width, :integer, :default => 0, :limit => 2
    change_column :infographics, :dynamic_height, :integer, :default => 0, :limit => 2

    # if value is nil update to 0
    Infographic.transaction do
      Infographic.where('dynamic_width is null').update_all(:dynamic_width => 0)
      Infographic.where('dynamic_height is null').update_all(:dynamic_height => 0)
    end
  end
end
