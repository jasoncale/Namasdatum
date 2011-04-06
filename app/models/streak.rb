# this is inspired by https://github.com/technoweenie/seinfeld/blob/37c22d64c65eee0eef63908406f7daf14be61342/lib/seinfeld/streak.rb

class Streak
  attr_accessor :started, :ended

  # start - First Date in the sequence that a commit was made.
  # ended - Last Date (or the current Date) in the sequence that a commit 
  #         was made.
  def initialize(started = nil, ended = nil)
    @started = started
    @ended   = ended || started
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

  # Public: Checks if the streak is current. Allow streaks from yesterday 
  # to count.
  #
  # date - The Date that we are checking against.  (default: Date.today)
  #
  # Returns true if the Streak is current, and false if it isn't.
  def current?(date = Date.today)
    @ended && (@ended + 1) >= date
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