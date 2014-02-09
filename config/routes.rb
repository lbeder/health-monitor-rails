HealthMonitor::Engine.routes.draw do
  controller :health do
    get :check
  end
end
