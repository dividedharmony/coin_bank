# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoinBank::Currency do
  describe "validations" do
    subject do
      described_class.new(
        name: "ByteCoin",
        symbol: "BYC",
        slug: "bytecoin"
      )
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:symbol) }
    it { is_expected.to validate_presence_of(:slug) }
  end
end
