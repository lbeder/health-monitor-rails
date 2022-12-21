# frozen_string_literal: true

require 'spec_helper'
require 'rspec/mocks'

module Providers
  include RSpec::Mocks::ExampleMethods

  extend self

  def stub_cache_failure
    allow(Rails.cache).to receive(:read).and_return(false)
  end

  def stub_database_failure(database = nil)
    if database.present?
      allow(ActiveRecord::Base).to receive(:establish_connection).with(database).and_raise(Exception)
    else
      allow(ActiveRecord::Base).to receive(:establish_connection).and_raise(Exception)
    end
  end

  def stub_delayed_job
    allow(Delayed::Job).to receive(:count).and_return(1)
  end

  def stub_delayed_job_queue_size_failure
    allow(Delayed::Job).to receive(:count).and_return(1000)
  end

  def stub_redis_failure
    allow_any_instance_of(MockRedis).to receive(:get).and_return(false)
  end

  def stub_redis_max_user_memory_failure
    allow_any_instance_of(MockRedis).to receive(:info).and_return('used_memory' => '1000000000')
  end

  def stub_resque_failure
    allow(Resque).to receive(:info).and_raise(Exception)
  end

  def stub_sidekiq
    stats = instance_double(Sidekiq::Stats)
    allow(stats).to receive(:processes_size).and_return(10)
    allow(Sidekiq::Stats).to receive(:new).and_return(stats)

    allow_any_instance_of(Sidekiq::Workers).to receive(:size).and_return(5)

    queue = instance_double(Sidekiq::Queue)
    allow(queue).to receive(:latency).and_return(5)
    allow(queue).to receive(:size).and_return(5)
    allow(Sidekiq::Queue).to receive(:new).and_return(queue)

    allow(Sidekiq).to receive(:redis_info).and_return(true)
  end

  def stub_sidekiq_workers_failure
    allow_any_instance_of(Sidekiq::Workers).to receive(:size).and_raise(Exception)
  end

  def stub_sidekiq_no_processes_failure
    stats = instance_double(Sidekiq::Stats)
    allow(stats).to receive(:processes_size).and_return(0)
    allow(Sidekiq::Stats).to receive(:new).and_return(stats)
  end

  def stub_sidekiq_latency_failure(queue_name = 'default')
    infinity_queue = instance_double(Sidekiq::Queue, latency: Float::INFINITY, size: 0)
    regular_queue = instance_double(Sidekiq::Queue, latency: 0, size: 0)
    allow(Sidekiq::Queue).to receive(:new).and_return(regular_queue)
    allow(Sidekiq::Queue).to receive(:new).with(queue_name).and_return(infinity_queue)
  end

  def stub_sidekiq_queue_size_failure(queue_name = 'default')
    infinity_queue = instance_double(Sidekiq::Queue, size: Float::INFINITY, latency: 0)
    regular_queue = instance_double(Sidekiq::Queue, size: HealthMonitor::Providers::Sidekiq::Configuration::DEFAULT_QUEUES_SIZE, latency: 0)
    allow(Sidekiq::Queue).to receive(:new).and_return(regular_queue)
    allow(Sidekiq::Queue).to receive(:new).with(queue_name).and_return(infinity_queue)
  end

  def stub_sidekiq_redis_failure
    allow(Sidekiq).to receive(:redis_info).and_raise(Redis::CannotConnectError)
  end
end
