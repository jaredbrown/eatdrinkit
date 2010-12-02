namespace :eatdrinkit do
  desc 'Downcase all user e-mails in the database'
  task :downcase_emails do
    Rake::Task['environment'].invoke
    
    users = User.find(:all)
    users.each do |user|
      puts user.email + ' -> ' + user.email.downcase
      user.email = user.email.downcase
      unless(user.save!)
        puts 'Could not downcase ' + user.email
      end
    end
  end
  
  task :default_enable_foursquare do
    Rake::Task['environment'].invoke
    
    users = User.find(:all)
    users.each do |user|
      user.enable_foursquare = false
      unless(user.save!)
        puts 'Could not set enable_foursquare default'
      end
    end
  end
  
  ask :default_enable_twitter do
    Rake::Task['environment'].invoke
    
    users = User.find(:all)
    users.each do |user|
      user.enable_twitter = false
      unless(user.save!)
        puts 'Could not set enable_twitter default'
      end
    end
  end
end