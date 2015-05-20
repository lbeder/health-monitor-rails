module HealthMonitor
  class HealthController < ActionController::Base
    if Rails.version.starts_with? '3'
      before_filter :authenticate_with_basic_auth
    else
      before_action :authenticate_with_basic_auth
    end

    # GET /health/check
    def check
      HealthMonitor.check!(request: request)

      self.status = :ok
      self.response_body = "Health check has passed: r#{Time.now.to_s(:db)}\n"
    rescue => e
      self.status = :service_unavailable
      self.response_body = "Health check has failed: #{Time.now.to_s(:db)}, error: #{e.message}\n"
    end

    private

    def process_with_silence(*args)
      Rails.logger.silence_stream(STDOUT) do
        Rails.logger.silence_stream(STDERR) do
          process_without_silence(*args)
        end
      end
    end

    alias_method_chain :process, :silence

    def authenticate_with_basic_auth
      return true unless HealthMonitor.configuration.basic_auth_credentials

      credentials = HealthMonitor.configuration.basic_auth_credentials
      authenticate_or_request_with_http_basic do |name, password|
        name == credentials[:username] && password == credentials[:password]
      end
    end
  end
end
