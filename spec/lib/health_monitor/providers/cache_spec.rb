require 'spec_helper'
require 'health_monitor/providers/cache'

describe HealthMonitor::Providers::Cache do
  it 'should succesfully check!' do
    expect {
      subject.check!
    }.not_to raise_error
  end

  context 'failing' do
    before do
      Providers.stub_cache_failure
    end

    it 'should fail check!' do
      expect {
        subject.check!
      }.to raise_error(HealthMonitor::Providers::CacheException)
    end
  end
end
