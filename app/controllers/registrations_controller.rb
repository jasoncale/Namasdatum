require 'foursquare'

class RegistrationsController < Devise::RegistrationsController
  
  before_filter :authenticate_user!, :only => [:foursquare_callback, :gowalla_callback]
  
  def edit
    set_foursquare_auth_url if current_user.foursquare_access_token.blank?
    set_gowalla_auth_url    if current_user.gowalla_access_token.blank?
  end
  
  def foursquare_callback    
    if params[:code]
      current_user.update_attribute(:foursquare_access_token, foursquare.access_token(params[:code], foursquare_callback_url))
    end
    redirect_to edit_user_registration_path
  end
  
  def gowalla_callback
    if params[:code]
      access_token = gowalla.web_server.get_access_token(params[:code], :redirect_uri => gowalla_callback_url)  
      current_user.update_attributes({
        :gowalla_access_token            => access_token.token,
        :gowalla_refresh_token           => access_token.refresh_token,
        :gowalla_access_token_expires_at => access_token.expires_at,
        :gowalla_username                => access_token['username']
      })
    end
    redirect_to edit_user_registration_path
  end
  
  protected
  
  def foursquare
    if current_user.foursquare_access_token.present?
      @foursquare ||= Foursquare::Base.new(current_user.foursquare_access_token)
    else
      @foursquare ||= Foursquare::Base.new(Settings.foursquare_app_id, Settings.foursquare_app_secret)
    end
  end
  
  def gowalla
    @gowalla = Gowalla::Client.new(:access_token => current_user.gowalla_access_token)
  end
  
  def set_foursquare_auth_url
    @foursquare_auth_url = foursquare.authorize_url(foursquare_callback_url)
  end
  
  def set_gowalla_auth_url
    @gowalla_auth_url = gowalla.web_server.authorize_url(:redirect_uri => gowalla_callback_url, :state => 1, :scope => 'read-write')
  end
  
end