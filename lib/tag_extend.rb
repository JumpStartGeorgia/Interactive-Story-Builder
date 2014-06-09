module TagExtend
  extend ActiveSupport::Concern

  included do
    scope :by_tag_name, -> name { where("name like ?", "%#{name}%") }

    def self.token_input_tags
        scoped.map{|t| {id: t.name, name: t.name }}
    end
  end
end
