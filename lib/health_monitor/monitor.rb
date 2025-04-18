# frozen_string_literal: true

require 'health_monitor/configuration'

module HealthMonitor
  STATUSES = {
    ok: 'OK',
    warning: 'WARNING',
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
      results: results,
      status: results.any? { |res| res[:status] == STATUSES[:error] } ? :service_unavailable : :ok,
      timestamp: Time.now.to_formatted_s(:rfc2822)
    }
  end

  def measure_response_time(&block)
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    block.call
    (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time).round(3)
  end

  private

  def provider_result(provider, request)
    monitor = provider
    monitor.request = request

    if HealthMonitor.configuration.response_threshold
      response_time = measure_response_time { monitor.check! }
    else
      monitor.check!
    end

    result_data(provider, response_time)
  rescue StandardError => e
    configuration.error_callback.try(:call, e)

    {
      name: provider.name,
      message: e.message,
      status: provider.critical ? STATUSES[:error] : STATUSES[:warning]
    }
  end

  def result_data(provider, response_time)
    {
      name: provider.name,
      message: '',
      status: STATUSES[:ok]
    }.tap do |result|
      if response_time
        result[:response_time] = response_time
        result[:slow_response] = true if HealthMonitor.configuration.response_threshold < response_time
      end
    end
  end
end

HealthMonitor.configure
