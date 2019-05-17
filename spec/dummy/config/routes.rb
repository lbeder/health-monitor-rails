# frozen_string_literal: true

Rails.application.routes.draw do
  mount HealthMonitor::Engine => '/health'
end
