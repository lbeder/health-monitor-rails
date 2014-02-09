require 'spec_helper'

describe HealthMonitor::Configuration do
  describe 'defaults' do
    it { subject.providers.should =~ [:database] }
    it { subject.error_callback.should be_nil }
  end
end
