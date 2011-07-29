module User::History
  extend ActiveSupport::Concern

  module InstanceMethods

    def fetch_lesson_history
      return if self.mindbodyonline_user.blank? || self.mindbodyonline_pw.blank?

      lessons_imported = []

      agent = Mechanize.new
      agent.redirect_ok = true

      # First we go to the studio homepage which creates the session.
      agent.get('https://clients.mindbodyonline.com/ASP/home.asp?studioid=1134') do |page|
        page.form_with(:name => "wsLaunch").click_button
      end

      # Next we log in using the user credentials
      agent.post(
        'https://clients.mindbodyonline.com/ASP/login_p.asp',
        "requiredtxtUserName" => self.mindbodyonline_user,
        "requiredtxtPassword" => self.mindbodyonline_pw
      )

      agent.get("https://clients.mindbodyonline.com/ASP/my_vh.asp?tabID=2") do |history_page|
        lessons_imported = record_lessons(history_page.root)
      end

      return lessons_imported
    end

    private

    def record_lessons(document)
      rows = document.css("table tr")
      lessons_imported = []

      if rows.length > 2
        rows[2..rows.length].each do |row|
         if row.css('td').length == 11
           date = row.at_css('td:nth-child(1)').inner_text.gsub(/\302\240/, ' ')
           time = row.at_css('td:nth-child(3)').inner_text.gsub(/\302\240/, ' ')
           teacher = row.at_css('td:nth-child(4)').inner_text.gsub(/\302\240/, ' ')
           studio = row.at_css('td:nth-child(5)').inner_text.gsub(/\302\240/, ' ').gsub('Hot Bikram Yoga', '').strip

           # format parsable date and remove any &nbsp;
           attended_at_time = DateTime.strptime([date, time].join(" ").strip, '%d/%m/%Y %H:%M %p').to_time
           attended_at_utc = Time.zone.local_to_utc(attended_at_time)

           begin
             lesson = self.lessons.create({
               :attended_at => attended_at_utc,
               :teacher => Teacher.find_or_create_by_name(teacher),
               :studio => Studio.find_or_create_by_name(studio)
             })

             if lesson.valid?
               lessons_imported << lesson
             end
           rescue ArgumentError => e
             p "Import caused error #{e}"
           end
         end
        end

        # purge any failed lessons
        lessons.reload
      end

      return lessons_imported
    end

  end
end