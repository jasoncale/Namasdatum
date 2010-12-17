class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :authentication_keys => [:username]
  
  devise :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username
  
  has_many :lessons

  def fetch_lesson_history
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
      record_lessons(history_page.root)
    end
  end
  
  def record_lessons(document)
    rows = document.css("table tr")    
    
    if rows.length > 2
      rows[2..rows.length].each do |row|
       if row.css('td').length == 11
         date = row.at_css('td:nth-child(1)').inner_text.gsub(/\302\240/, ' ')
         time = row.at_css('td:nth-child(3)').inner_text.gsub(/\302\240/, ' ')
         teacher = row.at_css('td:nth-child(4)').inner_text.gsub(/\302\240/, ' ')
         studio = row.at_css('td:nth-child(5)').inner_text.gsub(/\302\240/, ' ').gsub('Hot Bikram Yoga', '').strip

         # format parsable date and remove any &nbsp;
         date_to_parse = [date, time].join(" ").strip

         begin
           self.lessons.create({
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