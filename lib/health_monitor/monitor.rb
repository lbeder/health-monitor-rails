require 'health_monitor/configuration'

module HealthMonitor
  extend self

  attr_accessor :configuration

  def configure
    self.configuration ||= Configuration.new

    yield configuration if block_given?
  end

  def check!(request: nil)
    configuration.providers.each do |provider|
      require "health_monitor/providers/#{provider}"

      monitor = "HealthMonitor::Providers::#{provider.capitalize}".constantize.new(request: request)
      monitor.check!
    end
  rescue Exception => e
    configuration.error_callback.call(e) if configuration.error_callback
    raise
  end
end

HealthMonitor.configure
