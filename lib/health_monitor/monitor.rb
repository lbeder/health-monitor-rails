# frozen_string_literal: true

require 'health_monitor/configuration'

module HealthMonitor
  STATUSES = {
    ok: 'OK',
    error: 'ERROR'
  }.freeze

  extend self

  attr_accessor :configuration

  def configure
    self.configuration ||= Configuration.new

    yield configuration if block_given?
  end

  def check(request: nil, params: {})
    providers = configuration.providers
    if params[:providers].present?
      providers = providers.select { |provider| params[:providers].include?(provider.name.downcase) }
    end

    results = providers.map { |provider| provider_result(provider, request) }

    {
      results: results.map{ |c| c.without(:critical) },
      status: results.any? { |res| res[:status] != STATUSES[:ok] && res[:critical] } ? :service_unavailable : :ok,
      timestamp: Time.now.to_formatted_s(:rfc2822)
    }
  end

  private

  def provider_result(provider, request)
    monitor = provider
    monitor.request = request
    monitor.check!

    {
      name: provider.name,
      message: '',
      status: STATUSES[:ok],
      critical: provider.critical
    }
  rescue StandardError => e
    configuration.error_callback.try(:call, e)

    {
      name: provider.name,
      message: e.message,
      status: STATUSES[:error],
      critical: provider.critical
    }
  end
end

HealthMonitor.configure
