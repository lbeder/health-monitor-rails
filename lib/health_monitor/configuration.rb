module HealthMonitor
  class Configuration
    attr_accessor :providers, :error_callback, :basic_auth_credentials

    def initialize
      @providers = [:database]
    end
  end
end
