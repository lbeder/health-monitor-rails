# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor do
  let(:time) { Time.now.to_formatted_s(:rfc2822) }
  let(:request) { test_request }

  before do
    described_class.configuration = HealthMonitor::Configuration.new

    Timecop.freeze(time)
  end

  after do
    Timecop.return
  end

  describe '#configure' do
    describe 'providers' do
      it 'configures a single provider' do
        subject.configure(&:redis)

        expect(described_class.configuration.providers.length).to be(2)
        expect(described_class.configuration.providers.to_a.first).to be_a(HealthMonitor::Providers::Database)
        expect(described_class.configuration.providers.to_a.second).to be_a(HealthMonitor::Providers::Redis)
      end

      it 'configures a single provider with custom configuration' do
        subject.configure(&:redis).configure do |redis_config|
          redis_config.url = 'redis://user:pass@example.redis.com:90210/'
        end

        expect(described_class.configuration.providers.length).to be(2)
        expect(described_class.configuration.providers.to_a.first).to be_a(HealthMonitor::Providers::Database)
        expect(described_class.configuration.providers.to_a.second).to be_a(HealthMonitor::Providers::Redis)
      end

      it 'configures multiple providers' do
        subject.configure do |config|
          config.redis
          config.sidekiq
        end

        expect(described_class.configuration.providers.length).to be(3)
        expect(described_class.configuration.providers.to_a.first).to be_a(HealthMonitor::Providers::Database)
        expect(described_class.configuration.providers.to_a.second).to be_a(HealthMonitor::Providers::Redis)
        expect(described_class.configuration.providers.to_a.third).to be_a(HealthMonitor::Providers::Sidekiq)
      end

      it 'configures multiple providers with custom configuration' do
        subject.configure do |config|
          config.redis
          config.sidekiq.configure do |sidekiq_config|
            sidekiq_config.add_queue_configuration('critical', latency: 10.seconds, queue_size: 20)
          end
        end

        expect(described_class.configuration.providers.length).to be(3)
        expect(described_class.configuration.providers.to_a.first).to be_a(HealthMonitor::Providers::Database)
        expect(described_class.configuration.providers.to_a.second).to be_a(HealthMonitor::Providers::Redis)
        expect(described_class.configuration.providers.to_a.third).to be_a(HealthMonitor::Providers::Sidekiq)
      end
    end

    describe 'error_callback' do
      it 'configures' do
        error_callback = proc {}

        expect {
          subject.configure do |config|
            config.error_callback = error_callback
          end
        }.to change { described_class.configuration.error_callback }.to(error_callback)
      end
    end

    describe 'basic_auth_credentials' do
      it 'configures' do
        expected = {
          username: 'username',
          password: 'password'
        }

        expect {
          subject.configure do |config|
            config.basic_auth_credentials = expected
          end
        }.to change { described_class.configuration.basic_auth_credentials }.to(expected)
      end
    end
  end

  describe '#check' do
    context 'when default providers' do
      it 'succesfully checks' do
        expect(subject.check(request: request)).to eq(
          results: [
            {
              name: 'Database',
              message: '',
              status: 'OK'
            }
          ],
          status: :ok,
          timestamp: time
        )
      end
    end

    context 'when providers are not critical' do
      before do
        subject.configure do |config|
          config.redis.configure { |c| c.critical = false }
          config.sidekiq.configure { |c| c.critical = false }
        end
      end

      context 'with failed check' do
        before do
          Providers.stub_sidekiq_workers_failure
          Providers.stub_redis_failure
        end

        it 'returns results and succesful status' do
          expect(subject.check(request: request)).to eq(
            results: [
              {
                name: 'Database',
                message: '',
                status: 'OK'
              },
              {
                name: 'Redis',
                message: "different values (now: #{time}, fetched: false)",
                status: 'WARNING'
              },
              {
                name: 'Sidekiq',
                message: 'Exception',
                status: 'WARNING'
              }
            ],
            status: :ok,
            timestamp: time
          )
        end
      end
    end

    context 'when db and redis providers' do
      before do
        subject.configure(&:redis)
      end

      it 'succesfully checks' do
        expect(subject.check(request: request)).to eq(
          results: [
            {
              name: 'Database',
              message: '',
              status: 'OK'
            },
            {
              name: 'Redis',
              message: '',
              status: 'OK'
            }
          ],
          status: :ok,
          timestamp: time
        )
      end

      context 'when redis fails' do
        before do
          Providers.stub_redis_failure
        end

        it 'fails check' do
          expect(subject.check(request: request)).to eq(
            results: [
              {
                name: 'Database',
                message: '',
                status: 'OK'
              },
              {
                name: 'Redis',
                message: "different values (now: #{time}, fetched: false)",
                status: 'ERROR'
              }
            ],
            status: :service_unavailable,
            timestamp: time
          )
        end
      end

      context 'when sidekiq fails' do
        before do
          Providers.stub_sidekiq_workers_failure
        end

        it 'succesfully checks' do
          expect(subject.check(request: request)).to eq(
            results: [
              {
                name: 'Database',
                message: '',
                status: 'OK'
              },
              {
                name: 'Redis',
                message: '',
                status: 'OK'
              }
            ],
            status: :ok,
            timestamp: time
          )
        end
      end

      context 'when both redis and db fail' do
        before do
          Providers.stub_database_failure
          Providers.stub_redis_failure
        end

        it 'fails check' do
          expect(subject.check(request: request)).to eq(
            results: [
              {
                name: 'Database',
                message: 'unable to connect to: database1,database2',
                status: 'ERROR'
              },
              {
                name: 'Redis',
                message: "different values (now: #{time}, fetched: false)",
                status: 'ERROR'
              }
            ],
            status: :service_unavailable,
            timestamp: time
          )
        end
      end
    end

    context 'with error callback' do
      test = false

      let(:callback) do
        proc do |e|
          expect(e).to be_present
          expect(e).to be_is_a(Exception)

          test = true
        end
      end

      before do
        subject.configure do |config|
          config.error_callback = callback
        end

        Providers.stub_database_failure
      end

      it 'calls error_callback' do
        expect(subject.check(request: request)).to eq(
          results: [
            {
              name: 'Database',
              message: 'unable to connect to: database1,database2',
              status: 'ERROR'
            }
          ],
          status: :service_unavailable,
          timestamp: time
        )

        expect(test).to be_truthy
      end
    end
  end
end
