# frozen_string_literal: true

Dummy::Application.configure do
  config.cache_classes = true

  config.eager_load = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  config.active_support.to_time_preserves_timezone = :zone

  if Rails.version < '6.0' && config.active_record.sqlite3
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end
end
