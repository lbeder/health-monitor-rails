require 'spec_helper'
require 'health_monitor/Configuration'

describe HealthMonitor::Configuration do
  describe 'defaults' do
    it { subject.providers.should =~ [:database] }
    it { subject.error_callback.should be_nil }
  end
end
