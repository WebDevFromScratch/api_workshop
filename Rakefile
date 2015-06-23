begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

task :environment do
  require File.expand_path(File.join(*%w[ config environment ]), File.dirname(__FILE__))
end

namespace :db do
  desc 'Migrate the database'
  task migrate: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate('db/migrate')
  end

  desc 'Reverts last migration'
  task rollback: :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.rollback('db/migrate')
  end
end
