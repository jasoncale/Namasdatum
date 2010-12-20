desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
    
 # if Time.now.hour % 4 == 0 # run every four hours
   puts "Grabbing lesson data for each user."
   User.all.each do |user|
     user.fetch_lesson_history
   end
   puts "Done."
 # end

end