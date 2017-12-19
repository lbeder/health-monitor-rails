require 'health_monitor/configuration'

module HealthMonitor
  class HealthError < StandardError; end
  class HealthWarning < StandardError; end
  STATUSES = {
    ok: 'OK',
    error: 'ERROR',
    warn: 'WARN'
  }.freeze

  extend self

  attr_accessor :configuration

  def configure
    self.configuration ||= Configuration.new

    yield configuration if block_given?
  end

  def check(request: nil)
    results = configuration.providers.map { |provider| provider_result(provider, request) }

    {
      results: results,
      status: results.all? { |res| res[:status] == STATUSES[:ok] } ? :ok : :service_unavailable,
      timestamp: Time.now.to_s(:rfc2822)
    }
  end

  private

  def provider_result(provider, request)
    monitor = provider.new(request: request)
    monitor.check!
    {
      name: provider.provider_name,
      message: '',
      status: STATUSES[:ok]
    }
  rescue HealthWarning => e
    {
      name: provider.provider_name,
      message: e.message,
      status: STATUSES[:warn]
    }
  rescue => e
    configuration.error_callback.call(e) if configuration.error_callback
    {
      name: provider.provider_name,
      message: e.message,
      status: STATUSES[:error]
    }
  end
end

HealthMonitor.configure
