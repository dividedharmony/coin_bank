# frozen_string_literal: true

require "rails_helper"

RSpec.describe Results::Failure do
  let(:failure_result) { described_class.new(object: nil, message: 'failure message') }

  describe '#status' do
    subject { failure_result.status }

    it { is_expected.to eq(:failure) }
  end

  describe '#value!' do
    subject { failure_result.value! }
    
    it 'raises an error' do
      expect { subject }.to raise_error(
        Results::Failure::FailedValueError,
        'Cannot return a #value! for a Failure result'
      )
    end
  end

  describe '#bind' do
    it 'does not yield' do
      expect { |e| failure_result.bind(&e) }.not_to yield_control
    end

    it 'returns itself' do
      outcome = failure_result.bind do |_|
        'This block never actually runs'
      end
      expect(outcome).to eq(failure_result)
    end
  end

  describe '#fmap' do
    it 'does not yield' do
      expect { |e| failure_result.fmap(&e) }.not_to yield_control
    end

    it 'returns nil' do
      outcome = failure_result.fmap do |_|
        'This block never actually runs'
      end
      expect(outcome).to be_nil
    end
  end

  describe '#or' do
    it 'yields control' do
      expect { |e| failure_result.or(&e) }.to yield_control
    end
  end
end
