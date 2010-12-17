class PagesController < ApplicationController
  
  def index
    if user_signed_in?
      redirect_to user_path(current_user)
    else
      redirect_to new_user_registration_path
    end
  end
  
end
