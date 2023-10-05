# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'rails/all'

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
  end
end
