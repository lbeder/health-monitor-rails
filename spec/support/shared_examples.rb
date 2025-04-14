# frozen_string_literal: true

shared_examples 'expiring value in the redis' do
  context 'when a value being set' do
    let(:redis_key) { 'health:0.0.0.0' }

    it 'removes this one in the future' do
      subject.check!

      expect(subject.send(:redis).with { |r| r.get(redis_key) }).to be_present

      travel_to((described_class::EXPIRED_TIME_SECONDS + 1).seconds.since)

      expect(subject.send(:redis).with { |r| r.get(redis_key) }).to be_nil
    end
  end
end
