# frozen_string_literal: true

require "rails_helper"

RSpec.describe Accounting::Holdings do
  let(:holdings) { described_class.new }

  describe '#valuations' do
    subject { holdings.valuations }

    context 'if a currency is stable' do
      let!(:currency) { create(:currency, fiat: true) }

      it 'is excluded from valuation' do
        expect(subject.keys).to be_empty
      end
    end

    context 'if a currency is unstable' do
      let!(:currency) { create(:currency, :unstable) }

      it 'is included from valuation' do
        mock_valuation = instance_double(Accounting::Valuation, to_d: 13.57)
        expect(Accounting::Valuation).to receive(:new) { mock_valuation }
        expect(subject[currency.symbol]).to eq(13.57)
      end
    end
  end
end
