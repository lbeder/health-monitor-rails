HealthMonitor::Engine.routes.draw do
  get '/(.:format)', to: 'health#check'
end
