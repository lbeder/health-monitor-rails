# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'health_monitor/version'

Gem::Specification.new do |s|
  s.name = 'health-monitor-rails'
  s.version = HealthMonitor::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Leonid Beder']
  s.email = ['leonid.beder@gmail.com']
  s.license = 'MIT'
  s.homepage = 'https://github.com/lbeder/health-monitor-rails'
  s.summary = 'Health monitoring Rails plug-in, which checks various services (db, cache, sidekiq, redis, etc.)'
  s.description = 'Health monitoring Rails plug-in, which checks various services (db, cache, sidekiq, redis, etc.).'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.required_ruby_version = '>= 2.5'
  s.add_dependency 'railties', '>= 4.0'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'capybara-screenshot'
  s.add_development_dependency 'coveralls_reborn'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'delayed_job_active_record', '>= 4.1'
  s.add_development_dependency 'mock_redis'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'resque'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rake'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'sidekiq', '>= 3.0'
  s.add_development_dependency 'spork'
  s.add_development_dependency 'sqlite3', '>= 1.3'
  s.add_development_dependency 'timecop'

  s.metadata = {
    'rubygems_mfa_required' => 'true'
  }
end
