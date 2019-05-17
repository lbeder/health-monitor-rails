# frozen_string_literal: true

HealthMonitor::Engine.routes.draw do
  controller :health do
    get :check
  end
end
