namespace :dev do
  desc "Start the dev environment"
  task :start do
    monitor = Relay::TaskMonitor.new(
      tasks: %w[dev:server dev:sidekiq dev:assets]
    )
    monitor.prefork { Relay::DB.disconnect }
    monitor.monitor
  end

  desc "Serve the server"
  task :server do
    sh "env $(cat .env) " \
       "bundle exec falcon serve --bind http://0.0.0.0:9292"
  end

  desc "Run Sidekiq"
  task :sidekiq do
    sh "env $(cat .env) " \
       "bundle exec sidekiq -C app/config/sidekiq.yml -r ./app/init.rb"
  end

  desc "Watch frontend assets"
  task :assets do
    sh "npm --prefix app/assets run assets:watch"
  end
end
