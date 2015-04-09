require 'spec_helper'

describe HealthMonitor::Configuration do
  describe 'defaults' do
    it { expect(subject.providers).to eq(Set.new([:database])) }
    it { expect(subject.error_callback).to be_nil }
    it { expect(subject.basic_auth_credentials).to be_nil }
  end

  describe 'providers' do
    HealthMonitor::Configuration::PROVIDERS.each do |provider|
      before do
        subject.instance_variable_set('@providers', Set.new)

        stub_const("HealthMonitor::Providers::#{provider.capitalize}", Class.new)
      end

      it "responds to #{provider}" do
        expect(subject).to respond_to(provider)
      end

      it "configures #{provider}" do
        expect {
          subject.send(provider)
        }.to change { subject.providers }.to(Set.new([provider]))
      end

      it "returns #{provider}'s class" do
        expect(subject.send(provider)).to eq("HealthMonitor::Providers::#{provider.capitalize}".constantize)
      end
    end
  end
end
