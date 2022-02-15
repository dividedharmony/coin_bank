# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoinBank::Currency do
  describe "associations" do
    it { is_expected.to have_many(:balances).class_name("CoinBank::Balance") }
    it { is_expected.to have_many(:from_transactions).class_name("CoinBank::Transaction") }
    it { is_expected.to have_many(:to_transactions).class_name("CoinBank::Transaction") }
  end

  describe "validations" do
    subject do
      described_class.new(
        name: "ByteCoin",
        symbol: "BYC",
        slug: "bytecoin",
        cmc_id: "A123",
      )
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:symbol) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_presence_of(:cmc_id) }

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:symbol).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:slug).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:cmc_id).case_insensitive }
  end

  describe "#crypto?" do
    subject { currency.crypto? }

    context "if currency is a fiat currency" do
      let(:currency) { create(:currency, fiat: true) }

      it { is_expected.to be false }
    end

    context "if currency is not a fiat currency" do
      let(:currency) { create(:currency, fiat: false) }

      it { is_expected.to be true }
    end
  end
end
