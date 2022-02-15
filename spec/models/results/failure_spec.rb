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
    context 'if given block return value is not a Result class' do
      it 'raises an error' do
        expect do
          failure_result.or { 'Not a valid return value' }
        end.to raise_error(
          Results::Failure::InvalidOrReturnValue,
          'Return value for Failure#or block must be a Results::Base instance'
        )
      end
    end

    context 'if given block return value is a Success' do
      it 'returns the given success' do
        outcome = failure_result.or do
          Results::Success.new(object: 'New value', message: nil)
        end
        expect(outcome).to be_success
        expect(outcome.value!).to eq('New value')
      end
    end

    context 'if given block return value is a Failure' do
      it 'returns the given failure' do
        outcome = failure_result.or do |old_message|
          Results::Failure.new(object: nil, message: "New message/#{old_message}")
        end
        expect(outcome).to be_failure
        expect(outcome.message).to eq('New message/failure message')
      end
    end
  end

  describe '#or_map' do
    it 'yields control' do
      expect { |e| failure_result.or_map(&e) }.to yield_with_args('failure message')
    end

    it 'returns the yield value' do
      expect(
        failure_result.or_map { 'or block return value' }
      ).to eq('or block return value')
    end
  end
end
