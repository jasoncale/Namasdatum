# this is inspired by https://github.com/technoweenie/seinfeld/blob/37c22d64c65eee0eef63908406f7daf14be61342/lib/seinfeld/streak.rb

class Streak
  attr_accessor :started, :ended, :doubles, :double_last_used
  attr_reader :missed_days_limit, :double_valid_every
  
  # start - First Date in the sequence that a commit was made.
  # ended - Last Date (or the current Date) in the sequence that a commit 
  #         was made.
  def initialize(started = nil, ended = nil)
    @started = started
    @ended   = ended || started
    @doubles = []
    @missed_days_limit = 2
    @double_valid_every = 7.days
    @double_last_used = nil
  end

  # Public: Counts the number of days in the sequence, including the start 
  # and end.
  def days
    if @started && @ended
      1 + (@ended - @started).to_i.abs
    else
      0
    end
  end
  
  def double_on(date = Date.today)
    doubles << date.to_date
  end
  
  def double_in_last?(days = 7.days, now = Date.today)
    doubles_in_last(days, now).present?
  end
  
  def doubles_in_last(days = 7.days, now = Date.today)
    no_of_days = (days / 1.day).to_i
    doubles.select {|double_on| (now - double_on) < no_of_days }
  end
  
  # Public: Checks if the streak is current. Allow streaks from yesterday 
  # to count.
  #
  # date - The Date that we are checking against.  (default: Date.today)
  #
  # Returns true if the Streak is current, and false if it isn't.
  def current?(date = Date.today)
    current = @ended.present?
    if current 
      days_missed = (date - @ended).to_i    
      # must not miss 2 consecutive days
      current = days_missed < missed_days_limit  
      # unless double has occured
      if !current && days_missed <= missed_days_limit
        if double_in_last?(@double_valid_every, date) && (double_last_used.nil? || (date - double_last_used) > 7)
          current = true
          @double_last_used = doubles_in_last(7.days, date).first.to_date
        end
      end
    end
    return current
  end

  # Public: Checks if the given date is included in the sequence.
  #
  # date - The Date that we are checking.
  #
  # Returns true if the date is in the Streak, and false if it isn't.
  def include?(date)
    if @started && @ended
      @started <= date && @ended >= date
    else
      false
    end
  end

  def inspect
    %(#{@started ? ("#{@started.year}-#{@started.month}-#{@started.day}") : :nil}..#{@ended ? ("#{@ended.year}-#{@ended.month}-#{@ended.day}") : :nil}:Streak)
  end
end