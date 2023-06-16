# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor::Providers::Redis do
  subject { described_class.new }

  context 'with defaults' do
    it { expect(subject.configuration.name).to eq('Redis') }
    it { expect(subject.configuration.url).to eq(HealthMonitor::Providers::Redis::Configuration::DEFAULT_URL) }
  end

  describe '#name' do
    it { expect(subject.name).to eq('Redis') }
  end

  describe '#check!' do
    before { subject.request = test_request }

    context 'with a standard connection' do
      before do
        subject.configure do |config|
          config.connection = Redis.new
        end
      end

      it 'succesfully checks' do
        expect {
          subject.check!
        }.not_to raise_error
      end

      context 'when failing' do
        before do
          Providers.stub_redis_failure
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::RedisException)
        end
      end
    end

    context 'with a connection pool' do
      before do
        subject.configure do |config|
          config.connection = ConnectionPool.new(size: 5) { Redis.new }
        end
      end

      it 'succesfully checks' do
        expect {
          subject.check!
        }.not_to raise_error
      end

      context 'when failing' do
        before do
          Providers.stub_redis_failure
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::RedisException)
        end
      end
    end

    context 'with a custom connection' do
      class CustomRedisClient
        attr_reader :client

        delegate :info, to: :client
        delegate :get, to: :client
        delegate :set, to: :client

        def initialize
          @client = Redis.new
        end
      end

      let(:host) { 'fake.redis.com' }
      let(:port) { 91_210 }

      before do
        subject.configure do |config|
          config.connection = CustomRedisClient.new
        end
      end

      it 'succesfully checks' do
        expect {
          subject.check!
        }.not_to raise_error
      end

      context 'when failing' do
        before do
          Providers.stub_redis_failure
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::RedisException)
        end
      end
    end

    context 'with max_used_memory' do
      before do
        subject.configure do |config|
          config.max_used_memory = 100
        end
      end

      it 'succesfully checks' do
        expect {
          subject.check!
        }.not_to raise_error
      end

      context 'when failing' do
        before do
          Providers.stub_redis_max_user_memory_failure
        end

        it 'fails check!' do
          expect {
            subject.check!
          }.to raise_error(HealthMonitor::Providers::RedisException, '954Mb memory using is higher than 100Mb maximum expected')
        end
      end
    end
  end

  describe '#configure' do
    before do
      subject.configure
    end

    describe '#connection' do
      let(:redis_conenction) { 123 }

      it 'connection can be set directly dir' do
        expect {
          subject.configure do |config|
            config.connection = redis_conenction
          end
        }.to change { subject.configuration.connection }.to(redis_conenction)
      end
    end

    describe '#url' do
      let(:url) { 'redis://user:password@fake.redis.com:91210/' }

      it 'url can be configured' do
        expect {
          subject.configure do |config|
            config.url = url
          end
        }.to change { subject.configuration.url }.to(url)
      end
    end

    describe '#max_used_memory' do
      let(:max_used_memory) { 10 }

      it 'max_used_memory can be configured' do
        expect {
          subject.configure do |config|
            config.max_used_memory = max_used_memory
          end
        }.to change { subject.configuration.max_used_memory }.to(max_used_memory)
      end
    end
  end

  describe '#key' do
    before { subject.request = test_request }

    it { expect(subject.send(:key)).to eq('health:0.0.0.0') }
  end
end
