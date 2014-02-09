require 'spec_helper'
require 'health_monitor/providers/redis'

describe HealthMonitor::Providers::Redis do
  it 'should succesfully check!' do
    expect {
      subject.check!
    }.not_to raise_error
  end

  context 'failing' do
    before do
      Providers.stub_redis_failure
    end

    it 'should fail check!' do
      expect {
        subject.check!
      }.to raise_error(HealthMonitor::Providers::RedisException)
    end
  end
end
