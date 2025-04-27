# frozen_string_literal: true

module HealthMonitor
  class Configuration
    PROVIDERS = %i[cache database delayed_job file_absence redis resque sidekiq solr].freeze

    attr_accessor :basic_auth_credentials,
                  :environment_variables,
                  :error_callback,
                  :hide_footer,
                  :path,
                  :response_threshold
    attr_reader :providers

    def initialize
      database
    end

    def no_database
      @providers.shift
    end

    PROVIDERS.each do |provider_name|
      define_method provider_name do |&_block|
        require "health_monitor/providers/#{provider_name}"

        add_provider(
          "HealthMonitor::Providers::#{provider_name.to_s.titleize.delete(' ')}"
            .constantize.new
        )
      end
    end

    def add_custom_provider(custom_provider_class)
      unless custom_provider_class < HealthMonitor::Providers::Base
        raise ArgumentError.new 'custom provider class must implement HealthMonitor::Providers::Base'
      end

      add_provider(custom_provider_class.new)
    end

    private

    def add_provider(provider)
      (@providers ||= []) << provider

      provider
    end
  end
end
