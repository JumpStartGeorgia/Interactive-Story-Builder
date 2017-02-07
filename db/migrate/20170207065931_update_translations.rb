class UpdateTranslations < ActiveRecord::Migration
  def up
    StoryTypeTranslation.where({story_type_id: 5, locale: 'ru'}).update_all({name: "Инфографика"})
    StoryTypeTranslation.where({story_type_id: 5, locale: 'hy'}).update_all({name: "ինֆոգրաֆիկա"})
    StoryTypeTranslation.where({story_type_id: 5, locale: 'ka'}).update_all({name: "ინფოგრაფიკა"})
    StoryTypeTranslation.where({story_type_id: 5, locale: 'az'}).update_all({name: "infografika"})
    StoryTypeTranslation.where({story_type_id: 2, locale: 'az'}).update_all({name: "tok şou"})
    Language.where({locale: 'az'}).update_all({name: "Azərbaycan"})
  end

  def down
  end
end
