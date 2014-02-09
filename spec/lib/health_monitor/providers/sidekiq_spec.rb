require 'spec_helper'
require 'health_monitor/providers/sidekiq'

describe HealthMonitor::Providers::Sidekiq do
  it 'should succesfully check!' do
    expect {
      subject.check!
    }.not_to raise_error
  end

  context 'failing' do
    before do
      Providers.stub_sidekiq_failure
    end

    it 'should fail check!' do
      expect {
        subject.check!
      }.to raise_error
    end
  end
end
