module Providers
  extend self

  def stub_cache_failure
    Rails.cache.stub(:read).and_return(false)
  end

  def stub_database_failure
    ActiveRecord::Migrator.stub(:current_version).and_raise(Exception)
  end

  def stub_redis_failure
    Redis.any_instance.stub(:get).and_return(false)
  end

  def stub_sidekiq_failure
    Sidekiq::Workers.any_instance.stub(:size).and_raise(Exception)
  end
end
