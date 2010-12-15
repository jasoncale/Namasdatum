class Lesson < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :studio
  belongs_to :user
end
