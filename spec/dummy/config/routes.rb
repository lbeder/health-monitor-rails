Rails.application.routes.draw do
  mount HealthMonitor::Engine => '/health'
end
