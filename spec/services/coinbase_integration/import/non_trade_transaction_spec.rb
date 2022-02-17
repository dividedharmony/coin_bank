# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinbaseIntegration::Import::NonTradeTransaction do
  let(:currencies) { instance_double(CoinbaseIntegration::Currencies) }
  let(:non_trade_transaction) { described_class.new(currencies) }

  describe '#import!' do
    let(:user) { create(:user) }
    let(:dai_currency) { create(:currency, symbol: 'DAI') }
    let(:btc_currency) { create(:currency, symbol: 'BTC') }
    let(:raw_transaction) { double('Raw Transaction from Coinbase') }
    let!(:transacted_at) { 2.days.ago }
    let(:mock_struct) do
      instance_double(
        CoinbaseIntegration::TransactionStruct,
        from_currency_symbol: 'DAI',
        to_currency_symbol: 'BTC',
        from_amount: 12.34,
        to_amount: 299.99,
        native_amount: 112.56,
        exchange_rate: 11.22,
        transacted_at: transacted_at,
        coinbase_uuid: '5m8396-good-time-00142c3'
      )
    end

    subject { non_trade_transaction.import!(user, raw_transaction) }

    before do
      # mock currencies
      expect(currencies).to receive(:fetch).with('DAI') { dai_currency }
      expect(currencies).to receive(:fetch).with('BTC') { btc_currency }
      # mock TransactionStruct
      expect(CoinbaseIntegration::TransactionStruct).to receive(:new) { mock_struct }
    end

    it 'creates a Coin Bank Transaction' do
      expect { subject }.to change { CoinBank::Transaction.count }.from(0).to(1)
      aggregate_failures do
        expect(subject.user).to eq(user)
        expect(subject.from_currency).to eq(dai_currency)
        expect(subject.to_currency).to eq(btc_currency)
        expect(subject.from_amount).to eq(12.34)
        expect(subject.to_amount).to eq(299.99)
        expect(subject.native_amount).to eq(112.56)
        expect(subject.exchange_rate).to eq(11.22)
        expect(subject.transacted_at).to eq(transacted_at)
        expect(subject.coinbase_uuid).to eq('5m8396-good-time-00142c3')
      end
    end
  end
end
