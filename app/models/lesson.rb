class Lesson < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :studio
  belongs_to :user
  
  validates_uniqueness_of :attended_at, :on => :create, :scope => :user_id, :message => "a user cannot attendee the same lesson twice"
  
  scope :in_month, lambda { |month, year|
    where("year(attended_at) = ? AND month(attended_at) = ?", year, month)
  }
end
