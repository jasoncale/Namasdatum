class Achievement < ActiveRecord::Base
  has_and_belongs_to_many :users
  
  @achievement_conditions = {
    "30 Day Challenge" => Proc.new { |user| user.longest_streak >= 30 }
  }
  
  class << self    
    attr_reader :achievement_conditions
    
    def process_for(user)
      all.select do |achievement|
        achievement_conditions[achievement.name].call(user)
      end      
    end
  end  
end