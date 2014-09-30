require 'spec_helper'

describe HealthMonitor::Configuration do
  describe 'defaults' do
    it { expect(subject.providers).to match_array([:database]) }
    it { expect(subject.error_callback).to be_nil }
    it { expect(subject.basic_auth_credentials).to be_nil }
  end
end
