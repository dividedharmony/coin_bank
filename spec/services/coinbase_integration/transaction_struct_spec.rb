# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoinbaseIntegration::TransactionStruct do
  let(:transaction_type) { 'interest' }
  let(:native_amount) { '300.03' }
  let(:crypto_amount) { '0.03381622' }
  let(:transaction_struct) do
    described_class.new({
			"id" => "fake-2c8a-5f00-86bb-1c24b5e138ce",
			"type" => transaction_type,
			"status" => "completed",
			"amount" => {
				"amount" => crypto_amount,
				"currency" => "DAI"
			},
			"native_amount" => {
				"amount" => native_amount,
				"currency" => "CAD"
			},
			"created_at" => "2022-01-20T12:29:38Z",
			"updated_at" => "2022-01-20T12:29:38Z",
			"resource" => "transaction",
			"instant_exchange" => false,
			"from" => {
				"id" => "other-fake-5b33-9b8d-46a846983edf",
				"resource" => "user",
				"currency" => "DAI"
			},
			"details" => {
				"title" => "Dai reward",
				"subtitle" => "From Coinbase",
				"header" => "Received 0.03381622 DAI ($0.03)",
				"health" => "positive"
			},
			"hide_native_amount" => false
		})
  end

  describe '#type' do
    subject { transaction_struct.type }

    it { is_expected.to eq('interest') }
  end

  describe '#coinbase_uuid' do
    subject { transaction_struct.coinbase_uuid }

    it { is_expected.to eq('fake-2c8a-5f00-86bb-1c24b5e138ce') }
  end

  describe '#from_currency_symbol' do
    subject { transaction_struct.from_currency_symbol }

    context "if type is 'buy'" do
      let(:transaction_type) { 'buy' }

      it { is_expected.to eq('CAD') }
    end

    context 'if type is a reward type' do
      let(:transaction_type) { 'inflation_reward' }

      it { is_expected.to eq(CoinBank::Currency::REWARDS_SYMBOL) }
    end

    context "if type is 'sell'" do
      let(:transaction_type) { 'sell' }

      it { is_expected.to eq('DAI') }
    end

    context 'if type is none of the above' do
      let(:transaction_type) { 'NON-EXISTENT' }

      specify do
        expect { subject }.to raise_error(
          CoinbaseIntegration::TransactionStruct::UnknownTransactionType,
          'Unidentified transaction type "NON-EXISTENT"'
        )
      end
    end
  end

  describe '#from_amount' do
    subject { transaction_struct.from_amount }

    context 'if type is not "sell"' do
      let(:transaction_type) { 'buy' }

      it { is_expected.to eq(300.03) }
    end

    context 'if type is "sell"' do
      let(:transaction_type) { 'sell' }

      it { is_expected.to eq(BigDecimal('0.03381622')) }
    end
  end

  describe '#to_currency_symbol' do
    subject { transaction_struct.to_currency_symbol }

    context "if type is 'buy'" do
      let(:transaction_type) { 'buy' }

      it { is_expected.to eq('DAI') }
    end

    context 'if type is a reward type' do
      let(:transaction_type) { 'inflation_reward' }

      it { is_expected.to eq('DAI') }
    end

    context "if type is 'sell'" do
      let(:transaction_type) { 'sell' }

      it { is_expected.to eq('CAD') }
    end

    context 'if type is none of the above' do
      let(:transaction_type) { 'NON-EXISTENT' }

      specify do
        expect { subject }.to raise_error(
          CoinbaseIntegration::TransactionStruct::UnknownTransactionType,
          'Unidentified transaction type "NON-EXISTENT"'
        )
      end
    end
  end

  describe '#to_amount' do
    subject { transaction_struct.to_amount }

    context 'if type is not "sell"' do
      let(:transaction_type) { 'buy' }

      it { is_expected.to eq(BigDecimal('0.03381622')) }
    end

    context 'if type is "sell"' do
      let(:transaction_type) { 'sell' }

      it { is_expected.to eq(300.03) }
    end
  end

  describe '#exchange_rate' do
    let(:transaction_type) { 'sell' }

    subject { transaction_struct.exchange_rate }

    context 'if from_amount is zero' do
      let(:crypto_amount) { 0 }

      it { is_expected.to eq(0) }
    end

    context 'if from_amount is not zero' do
      let(:crypto_amount) { 3 }
      let(:native_amount) { 6 }

      it { is_expected.to eq(2) }
    end
  end

  describe '#transacted_at' do
    subject { transaction_struct.transacted_at }

    it { is_expected.to eq('2022-01-20T12:29:38Z'.to_datetime) }
  end
end
