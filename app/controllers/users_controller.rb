class UsersController < ApplicationController
  
  def show
    @user = User.find_by_username(params[:id])
    @current_time = Time.zone.now
    @lessons = @user.lessons.in_month(@current_time.month, @current_time.year)    
  end
  
end
