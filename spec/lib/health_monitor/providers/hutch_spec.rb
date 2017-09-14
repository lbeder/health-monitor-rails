require 'spec_helper'

describe HealthMonitor::Providers::Hutch do
  describe HealthMonitor::Providers::Hutch::Configuration do
    describe 'defaults' do
      it { expect(described_class.new.params).to eq(HealthMonitor::Providers::Hutch::Configuration::DEFAULT_CONFIG) }
    end
  end

  subject { described_class.new(request: test_request) }

  describe '#provider_name' do
    it { expect(described_class.provider_name).to eq('Hutch') }
  end

  describe '#check!' do
    it 'succesfully checks' do
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
      before do
        Providers.stub_hutch_failure
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(HealthMonitor::Providers::HutchException)
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

    let(:params) { {:mq_host=>'127.0.0.1', :mq_api_host=>'127.0.0.1', :mq_vhost=>'/', :mq_username=>'guest', :mq_password=>'guest'} }

    it 'sets configuration parameters that are specified' do
      expect {
        described_class.configure do |config|
          config.params = params
        end
      }.to change { described_class.new.configuration.params }.to(params)
    end
  end
end
