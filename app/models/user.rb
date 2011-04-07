class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :authentication_keys => [:username]
  
  devise :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, 
    :mindbodyonline_user, :mindbodyonline_pw, :streak_start, :streak_end, :current_streak, 
    :longest_streak, :longest_streak_start, :longest_streak_end
  
  validates_presence_of :username, :message => "can't be blank"
  validates_uniqueness_of :username, :message => "must be unique"
  
  has_many :lessons
  
  before_validation do
    self.username = self.username.downcase if attribute_present?("username")
  end
    
  def to_param
    self.username
  end
  
  def update_with_password(params={}) 
    if params[:password].blank? 
      params.delete(:password) 
      params.delete(:password_confirmation) if params[:password_confirmation].blank? 
    end 
    update_attributes(params) 
  end

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
    
    # if lessons_imported.length > 0
    #   update_progress(lessons_imported)
    # end
  
    return lessons_imported
  end
    
  def update_progress(imported_lessons, today = Date.today)
    streaks = [current_streak = Streak.new(streak_start, streak_end)]

    transaction do
      lessons_for_consideration = imported_lessons.reject(&:streak_recorded)
      streaks = scan_lessons_for_streaks(lessons_for_consideration)
      update_from_streaks(streaks, today)
      lessons_for_consideration.each(&:streak_recorded!)
      save!
    end
  end
  
  def scan_lessons_for_streaks(imported_lessons)
    days = imported_lessons.group_by(&:date).sort
    streaks = [current_streak = Streak.new(streak_start, streak_end)]
    
    days.each do |date, lessons|
      current_streak.double_on(date) if lessons.count > 1
      
      if current_streak.current?(date)
        current_streak.ended = date
      else
        streaks << (current_streak = Streak.new(date))
      end      
    end
    
    streaks
  end
  
  def streaks_between(from, to)
    scan_lessons_for_streaks(lessons.where('attended_at BETWEEN ? AND ?', from, to))    
  end
  
  def update_from_streaks(streaks, today)  
    highest_streak = streaks.empty? ? 0 : streaks.max { |a, b| a.days <=> b.days }
    if latest_streak = streaks.last
      self.streak_start   = latest_streak.started
      self.streak_end     = latest_streak.ended
      self.current_streak = latest_streak.current?(today) ? latest_streak.days : 0
    end
    if highest_streak.days > longest_streak.to_i
      self.longest_streak       = highest_streak.days
      self.longest_streak_start = highest_streak.started
      self.longest_streak_end   = highest_streak.ended
    end
  end
  
  def clear_progress
    update_attributes \
      :streak_start => nil, :streak_end => nil, :current_streak => nil,
      :longest_streak => nil, :longest_streak_start => nil, :longest_streak_end => nil
    lessons.streak_recorded.update_all(:streak_recorded => false)
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
         date_to_parse = [date, time].join(" ").strip

         begin
           lesson = self.lessons.create({
             :attended_at => DateTime.strptime(date_to_parse, '%d/%m/%Y %H:%M %p').to_time.in_time_zone,
             :teacher => Teacher.find_or_create_by_name(teacher),
             :studio => Studio.find_or_create_by_name(studio)
           })       
           
           lessons_imported << lesson if lesson.valid?     
         rescue ArgumentError => e
           p "Import caused error #{e}"
         end        
       end
      end  
    end    
  
    return lessons_imported
  end
  
end