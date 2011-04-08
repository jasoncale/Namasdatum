module User::Stats
  extend ActiveSupport::Concern

  included do
  end

  module InstanceMethods
    
    def update_progress(imported_lessons, today = Date.today)
      streaks = [current_streak = Streak.new(streak_start, streak_end)]

      transaction do
        lessons_for_consideration = imported_lessons.reject(&:streak_recorded)
        streaks = scan_lessons_for_streaks(lessons_for_consideration)
        update_from_streaks(streaks, today)
        lessons_for_consideration.each(&:streak_recorded!)
        update_achievements
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
    
    def update_achievements
      achievements << Achievement.process_for(self)
    end

    def clear_progress
      update_attributes \
        :streak_start => nil, :streak_end => nil, :current_streak => nil,
        :longest_streak => nil, :longest_streak_start => nil, :longest_streak_end => nil
      lessons.streak_recorded.update_all(:streak_recorded => false)
    end
  
  end
  
end