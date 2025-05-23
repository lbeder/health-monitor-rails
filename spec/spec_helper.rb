# frozen_string_literal: true

require 'rubygems'
require 'spork'
require 'sidekiq'

Spork.prefork do
  ENV['RAILS_ENV'] ||= 'test'

  require File.expand_path('dummy/config/environment.rb', __dir__)

  require 'rspec/rails'
  require 'database_cleaner'
  require 'pry'
  require 'timecop'
  require 'mock_redis'
  require 'sidekiq/testing'
  require 'webmock/rspec'

  Dir[File.expand_path('../lib/**/*.rb', __dir__)].sort.each { |f| require f }
  Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }

  RSpec.configure do |config|
    config.mock_with :rspec

    config.include ActiveSupport::Testing::TimeHelpers
    config.include Capybara::DSL

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before do
      DatabaseCleaner.start

      mock_redis = MockRedis.new
      allow(Redis).to receive(:new).and_return(mock_redis)

      Sidekiq::Testing.fake!
    end

    config.after do
      DatabaseCleaner.clean
    end

    config.after(:suite) do
      FileUtils.rm_rf(File.expand_path('test.sqlite3', __dir__))
    end
  end
end

def test_request
  if Rails.version >= '5.1'
    ActionController::TestRequest.create(ActionController::Metal)
  elsif Rails.version.start_with?('5')
    ActionController::TestRequest.create
  else
    ActionController::TestRequest.new
  end
end

def parse_xml(response)
  xml = response.body.gsub('type="symbol"', '')
  Hash.from_xml(xml)['hash']
end
