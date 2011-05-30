module User::AutoCheckin
  extend ActiveSupport::Concern

  included do
  end

  module InstanceMethods
    def auto_checkin_for(lessons)
      if foursquare_access_token.present?
        foursquare = Foursquare::Base.new(foursquare_access_token)
        checkins_today = foursquare.checkins.all(:afterTimestamp => last_foursquare_check)
        studios_visited = lessons.map(&:studio).uniq
        studios_visited.each do |studio|
          if studio.foursquare_venue_id.present? 
            unless checkins_today.map{|checkin| checkin.venue.id }.include?(studio.foursquare_venue_id)
              # check them in
              foursquare.checkins.create(:venueId => studio.foursquare_venue_id, :broadcast => "public")
            end
          end
        end    
      end
    end

    def last_foursquare_check
      1.day.ago.to_i
    end
  end
  
end