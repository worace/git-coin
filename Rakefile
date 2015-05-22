task :environment do
  require File.join(File.expand_path(File.dirname(__FILE__)), "app")
end

namespace :db do
  desc 'Run DB migrations'
  task :migrate => :environment do
   require 'sequel/extensions/migration'
   Sequel::Migrator.apply(GitCoin.database, 'db/migrations')
  end
end

# E.G. rake generate:migration[create_gitcoins]
namespace :generate do
  desc 'Generate a timestamped, empty Sequel migration.'
  task :migration, :name do |_, args|
    if args[:name].nil?
      puts 'You must specify a migration name (e.g. rake generate:migration[create_events])!'
      exit false
    end

    content = "Sequel.migration do\n  up do\n    \n  end\n\n  down do\n    \n  end\nend\n"
    timestamp = Time.now.to_i
    filename = File.join(File.dirname(__FILE__), 'db/migrations', "#{timestamp}_#{args[:name]}.rb")

    File.open(filename, 'w') do |f|
      f.puts content
    end

    puts "Created the migration #{filename}"
  end
end

