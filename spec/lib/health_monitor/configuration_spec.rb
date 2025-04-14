# frozen_string_literal: true

require 'spec_helper'

describe HealthMonitor::Configuration do
  describe 'defaults' do
    it do
      expect(subject.providers.length).to be(1)
      expect(subject.providers.first).to be_a(HealthMonitor::Providers::Database)
    end

    it { expect(subject.error_callback).to be_nil }
    it { expect(subject.basic_auth_credentials).to be_nil }
    it { expect(subject.path).to be_nil }
  end

  describe 'providers' do
    HealthMonitor::Configuration::PROVIDERS.each do |provider_name|
      before do
        subject.instance_variable_set('@providers', [])

        stub_const("HealthMonitor::Providers::#{provider_name.to_s.titleize.delete(' ')}", Class.new)
      end

      it "responds to #{provider_name}" do
        expect(subject).to respond_to(provider_name)
      end

      it "configures #{provider_name}" do
        subject.send(provider_name)

        expect(subject.providers.length).to be(1)
        expect(subject.providers.first).to be_a("HealthMonitor::Providers::#{provider_name.to_s.titleize.delete(' ')}".constantize)
      end

      it "returns #{provider_name}'s class" do
        expect(subject.send(provider_name)).to be_a("HealthMonitor::Providers::#{provider_name.to_s.titleize.delete(' ')}".constantize)
      end
    end
  end

  # TODO: consider defining/undefining between test runs
  class Foo < HealthMonitor::Providers::Base; end
  class Bar; end
  class BazBuz < HealthMonitor::Providers::Base; end

  # TODO: consider DRYing with in-house provider test cases
  describe 'custom providers' do
    CUSTOM_PROVIDERS = [Foo, BazBuz]

    CUSTOM_PROVIDERS.each do |provider_name|
      before do
        subject.instance_variable_set('@providers', [])
        subject.init_custom_providers([provider_name])
        stub_const("HealthMonitor::Providers::#{provider_name}", Class.new)
      end

      it "responds to #{provider_name}" do
        expect(subject).to respond_to(provider_name.to_s.underscore)
      end

      it "configures #{provider_name}" do
        subject.send(provider_name.to_s.underscore)

        expect(subject.providers.length).to be(1)
        expect(subject.providers.first).to be_a("HealthMonitor::Providers::#{provider_name}".constantize)
      end

      it "returns #{provider_name}'s class" do
        expect(subject.send(provider_name.to_s.underscore)).to be_a("HealthMonitor::Providers::#{provider_name}".constantize)
      end
    end
  end

  describe '#init_custom_providers' do
    before do
      subject.instance_variable_set('@providers', [])
    end

    context 'when inherits' do
     let(:provider_name) { Foo }

      it 'accepts' do
        expect {
          subject.init_custom_providers([provider_name])
        }.to_not raise_error(ArgumentError)
      end
    end

    context 'when does not inherit' do
      let(:provider_name) { Bar }

      it 'does not accept' do
        expect {
          subject.init_custom_providers([provider_name])
        }.to raise_error(ArgumentError, "custom provider class #{provider_name} must implement HealthMonitor::Providers::Base")
      end
    end
  end

  describe '#no_database' do
    it 'removes the default database check' do
      subject.no_database

      expect(subject.providers).to be_empty
    end

    context 'when there are multiple configured providers' do
      it 'removes only the default database check' do
        subject.redis
        subject.no_database

        expect(subject.providers.length).to be(1)
        expect(subject.providers.first).to be_a(HealthMonitor::Providers::Redis)
      end
    end
  end
end
