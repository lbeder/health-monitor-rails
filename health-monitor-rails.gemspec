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
  s.add_dependency 'railties', '>= 6.1'

  s.metadata = {
    'rubygems_mfa_required' => 'true'
  }
end
