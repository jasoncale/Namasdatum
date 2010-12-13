class Lesson < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :studio

  class << self
    def import(html)
      document = Nokogiri::HTML(html)
      rows = document.css("table tr")    
      rows[2..rows.length].each do |row|
        if row.css('td').length == 11
          date = row.at_css('td:nth-child(1)').inner_text.gsub(/\302\240/, ' ')
          time = row.at_css('td:nth-child(3)').inner_text.gsub(/\302\240/, ' ')
          teacher = row.at_css('td:nth-child(4)').inner_text.gsub(/\302\240/, ' ')
          studio = row.at_css('td:nth-child(5)').inner_text.gsub(/\302\240/, ' ').gsub('Hot Bikram Yoga', '').strip
          
          # format parsable date and remove any &nbsp;
          date_to_parse = [date, time].join(" ").strip
          
          begin
            Lesson.create({
              :attended_at => DateTime.strptime(date_to_parse, '%d/%m/%Y %H:%M %p').to_time.in_time_zone,
              :teacher => Teacher.find_or_create_by_name(teacher),
              :studio => Studio.find_or_create_by_name(studio)
            })            
          rescue ArgumentError => e
            p "Import caused error #{e}"
          end        
        end
      end
    end
  end

end
