require 'spec_helper'

describe HealthMonitor::Providers::Redis do
  describe HealthMonitor::Providers::Redis::Configuration do
    describe 'defaults' do
      it { expect(described_class.new.url).to eq(HealthMonitor::Providers::Redis::Configuration::DEFAULT_URL) }
    end
  end

  subject { described_class.new(request: test_request) }

  describe '#provider_name' do
    it { expect(described_class.provider_name).to eq('Redis') }
  end

  describe '#check!' do
    it 'succesfully checks' do
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
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

  describe '#configurable?' do
    it { expect(described_class).to be_configurable }
  end

  describe '#configure' do
    before do
      described_class.configure
    end

    describe '#connection' do
      let(:redis_conenction) { double :redis_conenction, close: true }

      it 'connection could be configured' do
        expect {
          described_class.configure do |config|
            config.connection = redis_conenction
          end
        }.to change { described_class.new.configuration.connection }.to(redis_conenction)
      end

      it 'connection configuration is persistent accross instnaces' do
        expect {
          described_class.configure do |config|
            config.connection = redis_conenction
          end

          described_class.new
        }.to change { described_class.new.configuration.connection }.to(redis_conenction)
      end
    end

    describe '#url' do
      let(:url) { 'redis://user:password@fake.redis.com:91210/' }

      it 'url can be configured' do
        expect {
          described_class.configure do |config|
            config.url = url
          end
        }.to change { described_class.new.configuration.url }.to(url)
      end

      it 'url configuration is persistent' do
        expect {
          described_class.configure do |config|
            config.url = url
          end

          HealthMonitor::Providers::Sidekiq.configure do |config|
            config.latency = 123
          end
        }.to change { described_class.new.configuration.url }.to(url)
      end

      it 'url configuration is persistent accross instnaces' do
        expect {
          described_class.configure do |config|
            config.url = url
          end

          described_class.new
        }.to change { described_class.new.configuration.url }.to(url)
      end
    end
  end

  describe '#key' do
    it { expect(subject.send(:key)).to eq('health:0.0.0.0') }
  end
end
