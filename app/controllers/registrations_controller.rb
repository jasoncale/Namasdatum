require 'foursquare'

class RegistrationsController < Devise::RegistrationsController
  def edit
    unless current_user && current_user.foursquare_access_token.present?
      @authorize_url = foursquare.authorize_url(foursquare_callback_url)    
    end
  end
  
  def foursquare_callback
    code = params[:code]
    current_user.update_attribute(:foursquare_access_token, foursquare.access_token(code, foursquare_callback_url))
    redirect_to edit_user_registration_path
  end
  
  protected
  
  def foursquare
    if current_user && current_user.foursquare_access_token.present?
      @foursquare ||= Foursquare::Base.new(current_user.foursquare_access_token)
    else
      @foursquare ||= Foursquare::Base.new(Settings.foursquare_app_id, Settings.foursquare_app_secret)
    end
  end
  
end