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
    allow_any_instance_of(ActiveRecord::ConnectionAdapters::SQLite3Adapter).to receive(:execute) do |instance|
      raise StandardError if !database.present? || instance.pool.db_config.name == database.to_s
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
    allow(queue).to receive_messages(latency: 5, size: 10)
    allow(Sidekiq::Queue).to receive(:new).and_return(queue)

    retry_set = instance_double(Sidekiq::RetrySet)
    allow(retry_set).to receive(:select).and_return([])
    allow(Sidekiq::RetrySet).to receive(:new).and_return(retry_set)

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

  def stub_sidekiq_over_retry_limit_failure
    retry_set = instance_double(Sidekiq::RetrySet)
    retry_count = ::HealthMonitor::Providers::Sidekiq::Configuration::DEFAULT_RETRY_CHECK + 1
    allow(retry_set).to receive(:select).and_return([item: { retry_count: retry_count }])
    allow(Sidekiq::RetrySet).to receive(:new).and_return(retry_set)
  end

  def stub_solr
    WebMock.stub_request(:get, 'http://www.example-solr.com:8983/solr/admin/cores?action=STATUS').to_return(
      body: { responseHeader: { status: 0 } }.to_json, headers: { 'Content-Type' => 'text/json' }
    )
  end

  def stub_solr_failure
    WebMock.stub_request(:get, 'http://www.example-solr.com:8983/solr/admin/cores?action=STATUS').to_return(
      body: { responseHeader: { status: 500 } }.to_json, headers: { 'Content-Type' => 'text/json' }
    )
  end

  def stub_solr_collection(collection, status: 200, body: { responseHeader: { status: 0 }, status: 'OK' }.to_json)
    WebMock.stub_request(:get, "http://www.example-solr.com:8983/solr/#{collection}/admin/ping")
           .to_return(body: body, headers: { 'Content-Type' => 'text/json' }, status: status)
  end

  def stub_solr_with_auth
    WebMock.stub_request(:get, 'http://localhost:8888/solr/admin/cores?action=STATUS')
           .with(headers: { 'Authorization' => 'Basic c29scjpTb2xyUm9ja3M=', 'Host' => 'localhost:8888' })
           .to_return(body: { responseHeader: { status: 0 } }.to_json, headers: { 'Content-Type' => 'text/json' })
  end

  def stub_solr_failure_with_auth
    WebMock.stub_request(:get, 'http://localhost:8888/solr/admin/cores?action=STATUS')
           .with(headers: { 'Authorization' => 'Basic c29scjpTb2xyUm9ja3M=', 'Host' => 'localhost:8888' })
           .to_return(body: { responseHeader: { status: 500 } }.to_json, headers: { 'Content-Type' => 'text/json' })
  end

  def stub_solr_collection_with_auth(collection, status: 200, body: { responseHeader: { status: 0 }, status: 'OK' }.to_json)
    WebMock.stub_request(:get, "http://localhost:8888/solr/#{collection}/admin/ping")
           .with(headers: { 'Authorization' => 'Basic c29scjpTb2xyUm9ja3M=', 'Host' => 'localhost:8888' })
           .to_return(body: body, headers: { 'Content-Type' => 'text/json' }, status: status)
  end
end
