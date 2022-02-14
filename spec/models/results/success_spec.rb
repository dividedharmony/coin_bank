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
    it 'yields the result object' do
      expect { |e| success_result.bind(&e) }.to yield_with_args('result object')
    end

    it 'returns itself' do
      outcome = success_result.bind do |string|
        "Discarded: #{string}"
      end
      expect(outcome).to eq(success_result)
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
    
    it { is_expected.to eq('result object') }

    it 'does not yield' do
      expect { |e| success_result.or(&e) }.not_to yield_control
    end
  end
end
