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

      v = HealthMonitor.configuration.environmet_variables.merge({ 'time' => Time.now.to_s(:db) })
      env_vars = [environmet_variables: v]
      res[:results] = env_vars + res[:results]

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
