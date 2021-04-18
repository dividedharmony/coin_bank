# frozen_string_literal: true

require "rails_helper"

RSpec.describe CmcClient, :vcr do
  describe "#info" do
    let(:symbol) { 'BTC' }
    let(:cmc_client) { described_class.new(environment: environment) }

    subject { cmc_client.info(symbol: symbol) }

    context "if given the test environment" do
      let(:environment) { instance_double(ActiveSupport::EnvironmentInquirer, test?: true) }

      it "queries the sandbox uri" do
        expect(Faraday).to receive(:get).with(
          "https://sandbox-api.coinmarketcap.com/v1/cryptocurrency/info",
          any_args
        ).and_call_original
        subject
      end

      context "if id does not exist" do
        let(:symbol) { 'SUPERFAKESYMBOL' }

        it "returns the error message wrapped in a Failure monad" do
          expect(subject).not_to be_success
          expect(subject.failure).to eq('Invalid value for "symbol": "SUPERFAKESYMBOL"')
        end
      end
  
      context "if id does exist" do
        let(:symbol) { 'ETH' }

        it "returns the response data wrapped in a Success monad" do
          expect(subject).to be_success
          response_data = subject.value!
          expect(response_data['name']).to eq('Ethereum')
          expect(response_data['slug']).to eq('ethereum')
          expect(response_data['logo']).to eq('https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png')
          expect(response_data['id']).to eq(1027)
        end
      end
    end

    context "if given any other environment" do
      let(:environment) { instance_double(ActiveSupport::EnvironmentInquirer, test?: false) }

      it "queries the production uri" do
        expect(Faraday).to receive(:get).with(
          "https://pro-api.coinmarketcap.com/v1/cryptocurrency/info",
          any_args
        ).and_call_original
        subject
      end
    end
  end
end
