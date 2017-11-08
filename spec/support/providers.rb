require 'spec_helper'

module Providers
  include RSpec::Mocks::ExampleMethods

  extend self

  def stub_cache_failure
    allow(Rails.cache).to receive(:read).and_return(false)
  end

  def stub_database_failure
    allow(ActiveRecord::Migrator).to receive(:current_version).and_raise(Exception)
  end

  def stub_redis_failure
    allow_any_instance_of(Redis).to receive(:get).and_return(false)
  end

  def stub_resque_failure
    allow(Resque).to receive(:info).and_raise(Exception)
  end

  def stub_sidekiq_workers_failure
    allow_any_instance_of(Sidekiq::Workers).to receive(:size).and_raise(Exception)
  end

  def stub_sidekiq_latency_failure
    allow_any_instance_of(Sidekiq::Queue).to receive(:latency).and_return(Float::INFINITY)
  end

  def stub_sidekiq_redis_failure
    allow(Sidekiq).to receive(:redis).and_raise(Redis::CannotConnectError)
  end

  def stub_hutch_failure
    allow(Hutch).to receive(:connect).and_raise(Hutch::ConnectionError)
  end

  def stub_memcached_failure
    allow_any_instance_of(Dalli::Client).to receive(:get).and_raise(Exception)
  end

  def stub_sidekiq_is_running
    allow_any_instance_of(Sidekiq::ProcessSet).to receive(:map).and_return([1])
  end
end
