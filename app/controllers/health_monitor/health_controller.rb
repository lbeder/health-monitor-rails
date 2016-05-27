module HealthMonitor
  class HealthController < ActionController::Base
    if Rails.version.starts_with? '3'
      before_filter :authenticate_with_basic_auth
    else
      before_action :authenticate_with_basic_auth
    end

    # GET /health/check
    def check
      res = HealthMonitor.check(request: request)

      unless HealthMonitor.configuration.environmet_variables.nil?
        env_vars = [environmet_variables: HealthMonitor.configuration.environmet_variables]
        res[:results] = env_vars + res[:results]
      end

      self.content_type = Mime[:json]
      self.status = res[:status]
      self.response_body = ActiveSupport::JSON.encode(res[:results])
    end

    private

    def authenticate_with_basic_auth
      return true unless HealthMonitor.configuration.basic_auth_credentials

      credentials = HealthMonitor.configuration.basic_auth_credentials
      authenticate_or_request_with_http_basic do |name, password|
        name == credentials[:username] && password == credentials[:password]
      end
    end
  end
end
