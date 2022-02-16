# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoinbaseIntegration::ApiHeaders do
  describe '#to_h' do
    let!(:timestamp) { 3.days.ago.to_i }

    subject do
      described_class.new(
        request_path: 'http://www.example.com/v2/accounts',
        body: nil,
        time: timestamp
      ).to_h
    end

    before do
      expect(ENV).to receive(:fetch).with('COINBASE_API_KEY') { 'FakeApiKey' }
      expect(ENV).to receive(:fetch).with('COINBASE_API_SECRET') { 'FakeSecretKey' }
    end

    it 'returns signed headers' do
      signature_content = "#{timestamp}GEThttp://www.example.com/v2/accounts"
      signature = OpenSSL::HMAC.hexdigest('sha256', 'FakeSecretKey', signature_content)
      expect(subject).to eq({
        "CB-ACCESS-KEY" => 'FakeApiKey',
        "CB-ACCESS-SIGN" => signature,
        "CB-ACCESS-TIMESTAMP" => timestamp.to_s,
        "CB-VERSION" => '2021-03-31',
        "Content-Type" => "application/json"
      })
    end
  end
end
