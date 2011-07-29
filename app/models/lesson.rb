class Lesson < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :studio
  belongs_to :user

  validates_uniqueness_of :attended_at, :on => :create, :scope => :user_id, :message => "a user cannot attendee the same lesson twice"

  scope :in_month, lambda { |month, year|
    where("EXTRACT(YEAR FROM lessons.attended_at) = ? AND EXTRACT(MONTH FROM lessons.attended_at) = ?", year, month)
  }

  scope :streak_recorded, where(:streak_recorded => true)
  scope :no_streak_recorded, where(:streak_recorded => false)

  def date
    attended_at.to_date
  end

  def streak_recorded!
    update_attribute(:streak_recorded, true)
  end
end
