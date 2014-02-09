require 'rubygems'
require 'spork'

Spork.prefork do
  ENV['RAILS_ENV'] ||= 'test'

  require File.expand_path('../dummy/config/environment.rb',  __FILE__)

  require 'rspec/rails'
  require 'database_cleaner'
  require 'pry'

  Dir[File.expand_path('../support/*.rb', __FILE__)].each{|f| require f }

  RSpec.configure do |config|
    config.mock_with :rspec

    # Exclude broken tests.
    config.filter_run_excluding :broken => true
    config.filter_run :focus => true
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.run_all_when_everything_filtered = true

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

    config.after(:suite) do
      FileUtils.rm_rf(File.expand_path('../test.sqlite3', __FILE__))
    end
  end
end

Spork.each_run do
end
