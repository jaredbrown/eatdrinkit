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
end