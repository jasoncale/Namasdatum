module User::AutoCheckin
  extend ActiveSupport::Concern

  included do
  end

  module InstanceMethods
    
    def process_geo_checkins
      practiced_today = lessons.where('attended_at >= ?', Date.today)
      auto_checkin_for(practiced_today)
    end
        
    def auto_checkin_for(lessons)
      studios_visited = lessons.map(&:studio).uniq
      checkins = studios_visited.collect do |studio| 
        foursquare_checkin(studio) 
      end
      checkins.flatten.select(&:present?)
    end

    def today_began_at
      Time.local(Date.today.year, Date.today.month, Date.today.day).to_i
    end

    def foursquare
      @foursquare ||= Foursquare::Base.new(foursquare_access_token)
    end

    def foursquare_enabled?
      foursquare_access_token.present?
    end   

    def foursquare_already_checked_in_at?(studio)
      foursquare_checkins_today.map{ |checkin| checkin.venue.id }.include?(studio.foursquare_venue_id)
    end

    private

    def foursquare_checkin(studio)
      if foursquare_enabled? && studio.foursquare_venue_id.present? 
        unless foursquare_already_checked_in_at?(studio)
          checkin = foursquare.checkins.create(:venueId => studio.foursquare_venue_id, :broadcast => "public")   
        end
      end
    end

    def foursquare_checkins_today
      foursquare.checkins.all(:afterTimestamp => today_began_at)
    end

  end
  
end