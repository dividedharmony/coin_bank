# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoinBank::Currency do
  describe "associations" do
    it { is_expected.to have_many(:balances).class_name("CoinBank::Balance") }
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
end
