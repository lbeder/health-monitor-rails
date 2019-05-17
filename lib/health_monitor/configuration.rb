# frozen_string_literal: true

module HealthMonitor
  class Configuration
    PROVIDERS = %i[cache database delayed_job redis resque sidekiq].freeze

    attr_accessor :error_callback, :basic_auth_credentials, :environment_variables
    attr_reader :providers

    def initialize
      database
    end

    def no_database
      @providers.delete(HealthMonitor::Providers::Database)
    end

    PROVIDERS.each do |provider_name|
      define_method provider_name do |&_block|
        require "health_monitor/providers/#{provider_name}"
        add_provider("HealthMonitor::Providers::#{provider_name.to_s.titleize.delete(' ')}".constantize)
      end
    end

    def add_custom_provider(custom_provider_class)
      unless custom_provider_class < HealthMonitor::Providers::Base
        raise ArgumentError.new 'custom provider class must implement '\
          'HealthMonitor::Providers::Base'
      end

      add_provider(custom_provider_class)
    end

    private

    def add_provider(provider_class)
      (@providers ||= Set.new) << provider_class

      provider_class
    end
  end
end
