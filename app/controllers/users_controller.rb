class UsersController < ApplicationController

  def show
    if @user = User.find_by_username(params[:id])
      @current_time = Time.zone.now
      @display_time = Time.local(params[:year] || @current_time.year, params[:month] || @current_time.month, @current_time.day, @current_time.hour)
      @lessons = @user.lessons.in_month(@display_time.month, @display_time.year)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

end
