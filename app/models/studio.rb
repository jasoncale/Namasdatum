class Studio < ActiveRecord::Base
  has_many :lessons
  validates_uniqueness_of :name
end
