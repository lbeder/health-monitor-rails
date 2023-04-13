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
        subject.instance_variable_set('@providers', Array.new)

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

  describe '#add_custom_provider' do
    before do
      subject.instance_variable_set('@providers', Array.new)
    end

    context 'when inherits' do
      class CustomProvider < HealthMonitor::Providers::Base
      end

      it 'accepts' do
        expect {
          subject.add_custom_provider(CustomProvider)
        }.to change(subject, :providers).to(Array.new([CustomProvider]))
      end

      it 'returns CustomProvider class' do
        expect(subject.add_custom_provider(CustomProvider)).to eq(CustomProvider)
      end
    end

    context 'when does not inherit' do
      class TestClass
      end

      it 'does not accept' do
        expect {
          subject.add_custom_provider(TestClass)
        }.to raise_error(ArgumentError)
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
