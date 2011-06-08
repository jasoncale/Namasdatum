module User::AutoCheckin
  extend ActiveSupport::Concern

  class GowallaCredentialsMissing < StandardError; end
  class FoursquareCredentialsMissing < StandardError; end

  included do
  end

  module InstanceMethods
    
    def process_geo_checkins
      practiced_today = lessons.where('attended_at >= ?', Date.today)
      auto_checkin_for(practiced_today)
    end
        
    def auto_checkin_for(lessons)
      studios_visited = lessons.map(&:studio).uniq
      checkins = []
      
      studios_visited.each do |studio| 
        checkins << foursquare_checkin(studio)
        checkins << gowalla_checkin(studio)
      end
      
      return checkins.select(&:present?)
    end

    def today_began_at
      Time.local(Date.today.year, Date.today.month, Date.today.day).to_i
    end

    def foursquare_client
      @foursquare_client ||= Foursquare::Base.new(foursquare_access_token)
    end

    def foursquare_enabled?
      foursquare_access_token.present?
    end   

    def foursquare_already_checked_in_at?(studio)
      foursquare_checkins_today.map{ |checkin| checkin.venue.id }.include?(studio.foursquare_venue_id)
    end
    
    def gowalla_client
      @gowalla_client ||= (
        ensure_gowalla_enabled!
        Gowalla::Client.new(:access_token => gowalla_access_token)
      )
    end
    
    def ensure_gowalla_enabled!
      raise GowallaCredentialsMissing unless gowalla_enabled?
    end
    
    def gowalla_enabled?
      gowalla_access_token.present? && gowalla_username.present?
    end
    
    def gowalla_already_checked_in_at?(studio)
      gowalla_checkins_today.map{ |checkin| checkin.venue.id }.include?(studio.gowalla_venue_id)
    end
    
    def gowalla_checkins_today
      ensure_gowalla_enabled!
      gowalla_client.user_events(gowalla_username).select { |checkin| checkin.created_at.to_date == Date.today }
    end

    private

    def foursquare_checkin(studio)
      if foursquare_enabled? && studio.foursquare_venue?
        unless foursquare_already_checked_in_at?(studio)
          checkin = foursquare_client.checkins.create(:venueId => studio.foursquare_venue_id, :broadcast => "public")   
        end
      end
    end

    def foursquare_checkins_today
      foursquare_client.checkins.all(:afterTimestamp => today_began_at)
    end

    def gowalla_checkin(studio)
      if gowalla_enabled? && studio.gowalla_venue?
        unless gowalla_already_checked_in_at?(studio)
          gowalla_client.checkin({
            :spot_id => studio.gowalla_venue_id, 
            :lat => studio.lat,
            :lng => studio.lng,
            :comment => "",
            :post_to_twitter => false,
            :post_to_facebook => false
          })
        end
      end
    end
    
  end
  
end