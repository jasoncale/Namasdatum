class UsersController < ApplicationController
  
  def show
    @current_time = Time.zone.now
    @lessons = current_user.lessons.in_month(@current_time.month, @current_time.year)    
  end
  
end
