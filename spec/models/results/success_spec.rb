# frozen_string_literal: true

require "rails_helper"

RSpec.describe Results::Success do
  let(:success_result) { described_class.new(object: 'result object', message: nil) }

  describe '#status' do
    subject { success_result.status }

    it { is_expected.to eq(:success) }
  end

  describe '#value!' do
    subject { success_result.value! }
    
    it { is_expected.to eq('result object') }
  end

  describe '#bind' do
    context 'if given block return value is not a Result class' do
      it 'raises an error' do
        expect do
          success_result.bind { |obj| "Not a valid return value: #{obj}" }
        end.to raise_error(
          Results::Success::InvalidBindReturnValue,
          'Return value for Success#bind block must be a Results::Base instance'
        )
      end
    end

    context 'if given block return value is a Success' do
      it 'returns the given success' do
        outcome = success_result.bind do |string|
          Results::Success.new(object: "New value from: #{string}", message: nil)
        end
        expect(outcome).to be_success
        expect(outcome.value!).to eq('New value from: result object')
      end
    end

    context 'if given block return value is a Failure' do
      it 'returns the given failure' do
        outcome = success_result.bind do |string|
          Results::Failure.new(object: nil, message: "Failure from: #{string}")
        end
        expect(outcome).to be_failure
        expect(outcome.message).to eq('Failure from: result object')
      end
    end
  end

  describe '#fmap' do
    it 'yields the result object' do
      expect { |e| success_result.fmap(&e) }.to yield_with_args('result object')
    end

    it 'returns the block value' do
      outcome = success_result.fmap do |string|
        "Outcome: #{string}"
      end
      expect(outcome).to eq('Outcome: result object')
    end
  end

  describe '#or' do
    subject { success_result.or }
    
    it { is_expected.to eq(success_result) }

    it 'does not yield' do
      expect { |e| success_result.or(&e) }.not_to yield_control
    end
  end

  describe '#or_map' do
    subject { success_result.or_map }

    it { is_expected.to eq('result object') }

    it 'does not yield' do
      expect { |e| success_result.or(&e) }.not_to yield_control
    end
  end
end
