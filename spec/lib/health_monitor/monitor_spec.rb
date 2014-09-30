require 'spec_helper'

describe HealthMonitor do
  before do
    HealthMonitor.configuration = HealthMonitor::Configuration.new
  end

  describe '#configure' do
    describe 'providers' do
      it 'should configure' do
        expect {
          subject.configure do |config|
            config.providers = [:sidekiq, :spec]
          end
        }.to change { HealthMonitor.configuration.providers }.to([:sidekiq, :spec])
      end

      it 'should be able to append' do
        expect {
          subject.configure do |config|
            config.providers += [:resque, :spec]
          end
        }.to change { HealthMonitor.configuration.providers }.to([:database, :resque, :spec])
      end
    end

    describe 'error_callback' do
      it 'should configure' do
        error_callback = proc { }
        expect {
          subject.configure do |config|
            config.error_callback = error_callback
          end
        }.to change { HealthMonitor.configuration.error_callback }.to(error_callback)
      end
    end

    describe 'basic_auth_credentials' do
      it 'should configure' do
        expected = {
          username: 'Some-Username',
          password: 'Some-Password'
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
      it 'should succesfully check!' do
        expect {
          subject.check!
        }.not_to raise_error
      end
    end

    context 'db and redis providers' do
      before do
        subject.configure do |config|
          config.providers = [:database, :redis]
        end
      end

      it 'should succesfully check!' do
        expect {
          subject.check!
        }.not_to raise_error
      end

      context 'redis fails' do
        before do
          Providers.stub_redis_failure
        end

        it 'should fail check!' do
          expect {
            subject.check!
          }.to raise_error
        end
      end

      context 'sidekiq fails' do
        before do
          Providers.stub_sidekiq_workers_failure
        end

        it 'should succesfully check!' do
          expect {
            subject.check!
          }.not_to raise_error
        end
      end
    end

    context 'with error callback' do
      test = false
      let(:error_callback) { proc do |e|
          expect(e).to be_present
          expect(e).to be_is_a(Exception)

          test = true
        end
      }

      before do
        subject.configure do |config|
          config.error_callback = error_callback
        end

        Providers.stub_database_failure
      end

      it 'calls error_callback' do
        expect {
          subject.check!
        }.to raise_error

        expect(test).to be_truthy
      end
    end
  end
end
