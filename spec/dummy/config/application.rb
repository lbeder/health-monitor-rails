# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'rails/all'

Bundler.require(*Rails.groups)

ActiveRecord.legacy_connection_handling = false

module Dummy
  class Application < Rails::Application
  end
end
