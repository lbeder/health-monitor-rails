# frozen_string_literal: true

module HealthMonitor
  class Configuration
    PROVIDERS = %i[cache database delayed_job file_absence redis resque sidekiq solr].freeze

    attr_accessor :basic_auth_credentials,
                  :environment_variables,
                  :error_callback,
                  :hide_footer,
                  :path
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

    # TODO: update README.md
    def init_custom_providers(provider_names)
      provider_names.each do |provider_name|
        add_custom_provider(provider_name)
      end
    end

    private

    def add_custom_provider(provider_name)
      unless provider_name < HealthMonitor::Providers::Base
        raise ArgumentError.new "custom provider class #{provider_name} must implement HealthMonitor::Providers::Base"
      end

      self.class.define_method(provider_name.to_s.underscore) do |&_block|
        add_provider("HealthMonitor::Providers::#{provider_name}".constantize.new)
      end
    end

    def add_provider(provider)
      (@providers ||= []) << provider

      provider
    end
  end
end
