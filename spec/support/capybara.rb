# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/rails'
require 'capybara-screenshot/rspec'

Capybara.app = HealthMonitor::Engine

RSpec.configure do |config|
  config.include HealthMonitor::Engine.routes.url_helpers
end
