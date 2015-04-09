require 'spec_helper'

describe HealthMonitor::Providers::Resque do
  subject { described_class.new(request: ActionController::TestRequest.new) }

  describe '#check!' do
    it 'succesfully checks' do
      expect {
        subject.check!
      }.not_to raise_error
    end

    context 'failing' do
      before do
        Providers.stub_resque_failure
      end

      it 'fails check!' do
        expect {
          subject.check!
        }.to raise_error(HealthMonitor::Providers::ResqueException)
      end
    end
  end

  describe '#configurable?' do
    it { expect(described_class).not_to be_configurable }
  end
end
