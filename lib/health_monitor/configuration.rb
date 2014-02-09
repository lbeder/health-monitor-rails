module HealthMonitor
  class Configuration
    attr_accessor :providers, :error_callback

    def initialize
      @providers = [:database]
    end
  end
end
