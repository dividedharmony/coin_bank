# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinBank::Transaction, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user).class_name("CoinBank::User").required }
    it { is_expected.to belong_to(:from_currency).class_name("CoinBank::Currency").required }
    it { is_expected.to belong_to(:to_currency).class_name("CoinBank::Currency").required }
  end

  describe "validations" do
    let(:transaction) { build(:transaction) }

    subject { transaction }

    it { is_expected.to validate_presence_of(:transacted_at) }
    it { is_expected.to validate_numericality_of(:from_amount) }
    it { is_expected.to validate_numericality_of(:to_amount) }
    it { is_expected.to validate_numericality_of(:exchange_rate) }
  end
end
