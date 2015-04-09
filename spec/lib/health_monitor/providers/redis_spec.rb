require 'spec_helper'

describe HealthMonitor::Providers::Redis do
  subject { described_class.new(request: ActionController::TestRequest.new) }

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
    it { expect(described_class).not_to be_configurable }
  end

  describe '#key' do
    it { expect(subject.send(:key)).to eq('health:0.0.0.0') }
  end
end
