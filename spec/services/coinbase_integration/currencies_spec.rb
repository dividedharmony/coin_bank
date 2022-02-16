# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoinbaseIntegration::Currencies do
  let(:usd_currency) { create(:currency, symbol: 'USD') }
  let(:reward_currency) { create(:currency, symbol: 'REWARDS') }
  let(:currencies) do
    described_class.new(
      usd_currency,
      reward_currency
    )
  end

  describe 'currencies initialized with' do
    it 'stores them for later retrieval' do
      expect(currencies.fetch('USD')).to eq(usd_currency)
      expect(currencies.fetch('REWARDS')).to eq(reward_currency)
    end
  end

  describe '#fetch' do
    subject { currencies.fetch('ZAP') }

    context 'if currency with symbol is already persisted' do
      let!(:currency) { create(:currency, symbol: 'ZAP') }

      it { is_expected.to eq(currency) }
    end

    context 'if currency with symbol is not yet persisted' do
      context 'if currency can be created' do
        before do
          expect(CoinBank::CreateCurrency).to receive(:call).with({
            coin_bank_currency: {
              symbol: 'ZAP'
            }
          }) do
            Results::Success.new(
              object: create(:currency, symbol: 'ZAP', name: 'ARTICUNO'),
              message: nil
            )
          end
        end

        specify do
          expect(subject.name).to eq('ARTICUNO')
        end
      end

      context 'if currency cannot be created' do
        before do
          expect(CoinBank::CreateCurrency).to receive(:call).with({
            coin_bank_currency: {
              symbol: 'ZAP'
            }
          }) do
            Results::Failure.new(
              object: nil,
              message: 'Database is imaginary.'
            )
          end
        end

        it 'raises an error' do
          expect { subject }.to raise_error(
            CoinbaseIntegration::Currencies::CouldNotFindOrCreate,
            'Could not find or create currency with symbol "ZAP"'
          )
        end
      end
    end
  end

  describe '#[]' do
    subject { currencies['ZAP'] }

    context 'if currency with symbol is already persisted' do
      let!(:currency) { create(:currency, symbol: 'ZAP') }

      it 'returns Success result' do
        expect(subject).to be_success
        expect(subject.value!).to eq(currency)
      end
    end

    context 'if currency with symbol is not yet persisted' do
      context 'if currency can be created' do
        before do
          expect(CoinBank::CreateCurrency).to receive(:call).with({
            coin_bank_currency: {
              symbol: 'ZAP'
            }
          }) do
            Results::Success.new(
              object: create(:currency, symbol: 'ZAP', name: 'ZAPADOS'),
              message: nil
            )
          end
        end

        it 'returns Success result' do
          expect(subject).to be_success
          expect(subject.value!.name).to eq('ZAPADOS')
        end
      end

      context 'if currency cannot be created' do
        before do
          expect(CoinBank::CreateCurrency).to receive(:call).with({
            coin_bank_currency: {
              symbol: 'ZAP'
            }
          }) do
            Results::Failure.new(
              object: nil,
              message: 'Database is imaginary.'
            )
          end
        end

        it 'returns Failure result' do
          expect(subject).to be_failure
          expect(subject.message).to eq('Database is imaginary.')
        end
      end
    end
  end
end
