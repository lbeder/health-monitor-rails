# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor do
  let(:time) { Time.local(1990) }

  before do
    HealthMonitor.configuration = HealthMonitor::Configuration.new

    Timecop.freeze(time)
  end

  let(:request) { test_request }

  after do
    Timecop.return
  end

  describe '#configure' do
    describe 'providers' do
      it 'configures a single provider' do
        expect {
          subject.configure(&:redis)
        }.to change { HealthMonitor.configuration.providers }
          .to(Set.new([HealthMonitor::Providers::Database, HealthMonitor::Providers::Redis]))
      end

      it 'configures a single provider with custom configuration' do
        expect {
          subject.configure(&:redis).configure do |redis_config|
            redis_config.url = 'redis://user:pass@example.redis.com:90210/'
          end
        }.to change { HealthMonitor.configuration.providers }
          .to(Set.new([HealthMonitor::Providers::Database, HealthMonitor::Providers::Redis]))
      end

      it 'configures a multiple providers' do
        expect {
          subject.configure do |config|
            config.redis
            config.sidekiq
          end
        }.to change { HealthMonitor.configuration.providers }
          .to(Set.new([HealthMonitor::Providers::Database, HealthMonitor::Providers::Redis,
            HealthMonitor::Providers::Sidekiq]))
      end

      it 'configures multiple providers with custom configuration' do
        expect {
          subject.configure do |config|
            config.redis
            config.sidekiq.configure do |sidekiq_config|
              sidekiq_config.add_queue_configuration('critical', latency: 10.seconds, queue_size: 20)
            end
          end
        }.to change { HealthMonitor.configuration.providers }
          .to(Set.new([HealthMonitor::Providers::Database, HealthMonitor::Providers::Redis,
            HealthMonitor::Providers::Sidekiq]))
      end

      it 'appends new providers' do
        expect {
          subject.configure(&:resque)
        }.to change { HealthMonitor.configuration.providers }.to(Set.new([HealthMonitor::Providers::Database,
          HealthMonitor::Providers::Resque]))
      end
    end

    describe 'error_callback' do
      it 'configures' do
        error_callback = proc do
        end

        expect {
          subject.configure do |config|
            config.error_callback = error_callback
          end
        }.to change { HealthMonitor.configuration.error_callback }.to(error_callback)
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
        }.to change { HealthMonitor.configuration.basic_auth_credentials }.to(expected)
      end
    end
  end

  describe '#check' do
    context 'default providers' do
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
          timestamp: time.to_s(:rfc2822)
        )
      end
    end

    context 'db and redis providers' do
      before do
        subject.configure do |config|
          config.database
          config.redis
        end
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
          timestamp: time.to_s(:rfc2822)
        )
      end

      context 'redis fails' do
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
            timestamp: time.to_s(:rfc2822)
          )
        end
      end

      context 'sidekiq fails' do
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
            timestamp: time.to_s(:rfc2822)
          )
        end
      end

      context 'both redis and db fail' do
        before do
          Providers.stub_database_failure
          Providers.stub_redis_failure
        end

        it 'fails check' do
          expect(subject.check(request: request)).to eq(
            results: [
              {
                name: 'Database',
                message: 'Exception',
                status: 'ERROR'
              },
              {
                name: 'Redis',
                message: "different values (now: #{time}, fetched: false)",
                status: 'ERROR'
              }
            ],
            status: :service_unavailable,
            timestamp: time.to_s(:rfc2822)
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
          config.database

          config.error_callback = callback
        end

        Providers.stub_database_failure
      end

      it 'calls error_callback' do
        expect(subject.check(request: request)).to eq(
          results: [
            {
              name: 'Database',
              message: 'Exception',
              status: 'ERROR'
            }
          ],
          status: :service_unavailable,
          timestamp: time.to_s(:rfc2822)
        )

        expect(test).to be_truthy
      end
    end
  end
end
