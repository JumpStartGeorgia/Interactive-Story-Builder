class Author < ActiveRecord::Base
  translates :name, :about, :permalink

  has_many :author_translations, :dependent => :destroy
  accepts_nested_attributes_for :author_translations

  attr_accessible :about, :name, :permalink, :author_translations_attributes

end
