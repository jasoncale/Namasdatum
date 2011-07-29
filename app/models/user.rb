require 'foursquare'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :authentication_keys => [:username]
  devise :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username,
    :mindbodyonline_user, :mindbodyonline_pw, :streak_start, :streak_end, :current_streak,
    :longest_streak, :longest_streak_start, :longest_streak_end, :foursquare_access_token,
    :gowalla_access_token, :gowalla_refresh_token, :gowalla_access_token_expires_at,
    :gowalla_username

  validates_presence_of :username, :message => "can't be blank"
  validates_uniqueness_of :username, :message => "must be unique"

  include User::History
  include User::Stats
  include User::AutoCheckin

  has_many :lessons
  has_and_belongs_to_many :achievements

  before_validation do
    self.username = self.username.downcase if attribute_present?("username")
  end

  def to_param
    self.username
  end

  def update_with_password(params={})
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    update_attributes(params)
  end

  def process_data
    lessons_imported = fetch_lesson_history

    if lessons_imported.present?
      # calculate stats
      update_progress(lessons_imported)
      # auto geo checkin (4sq, gowalla)
      process_geo_checkins
    end

    return lessons_imported
  end

end