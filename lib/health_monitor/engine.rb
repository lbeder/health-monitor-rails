# frozen_string_literal: true

module HealthMonitor
  class Engine < ::Rails::Engine
    isolate_namespace HealthMonitor
  end
end
