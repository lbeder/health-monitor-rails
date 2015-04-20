require 'spec_helper'

describe HealthMonitor do
  before do
    HealthMonitor.configuration = HealthMonitor::Configuration.new
  end

  let(:request) { ActionController::TestRequest.new }

  describe '#configure' do
    describe 'providers' do
      it 'configures a single provider' do
        expect {
          subject.configure do |config|
            config.redis
          end
        }.to change { HealthMonitor.configuration.providers }.
          to(Set.new([HealthMonitor::Providers::Database, HealthMonitor::Providers::Redis]))
      end

      it 'configures a multiple providers' do
        expect {
          subject.configure do |config|
            config.redis
            config.sidekiq
          end
        }.to change { HealthMonitor.configuration.providers }.
          to(Set.new([HealthMonitor::Providers::Database, HealthMonitor::Providers::Redis,
            HealthMonitor::Providers::Sidekiq]))
      end

      it 'appends new providers' do
        expect {
          subject.configure do |config|
            config.resque
          end
        }.to change { HealthMonitor.configuration.providers }.
          to(Set.new([HealthMonitor::Providers::Database, HealthMonitor::Providers::Resque]))
      end
    end

    describe 'error_callback' do
      it 'configures' do
        error_callback = proc { }

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

  describe '#check!' do
    context 'default providers' do
      it 'succesfully checks' do
        expect {
          subject.check!(request: request)
        }.not_to raise_error
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
        expect {
          subject.check!(request: request)
        }.not_to raise_error
      end

      context 'redis fails' do
        before do
          Providers.stub_redis_failure
        end

        it 'fails check!' do
          expect {
            subject.check!(request: request)
          }.to raise_error
        end
      end

      context 'sidekiq fails' do
        before do
          Providers.stub_sidekiq_workers_failure
        end

        it 'succesfully checks' do
          expect {
            subject.check!(request: request)
          }.not_to raise_error
        end
      end
    end

    context 'with error callback' do
      test = false

      let(:callback) {
        proc do |e|
          expect(e).to be_present
          expect(e).to be_is_a(Exception)

          test = true
        end
      }

      before do
        subject.configure do |config|
          config.database

          config.error_callback = callback
        end

        Providers.stub_database_failure
      end

      it 'calls error_callback' do
        expect {
          subject.check!(request: request)
        }.to raise_error

        expect(test).to be_truthy
      end
    end
  end
end
