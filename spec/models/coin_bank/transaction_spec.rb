# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinBank::Transaction, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user).class_name("CoinBank::User").required }
    it { is_expected.to belong_to(:from_before_balance).class_name("CoinBank::Balance").required }
    it { is_expected.to belong_to(:from_after_balance).class_name("CoinBank::Balance").required }
    it { is_expected.to belong_to(:to_before_balance).class_name("CoinBank::Balance").required }
    it { is_expected.to belong_to(:to_after_balance).class_name("CoinBank::Balance").required }
  end

  describe "validations" do
    subject { build(:transaction) }

    it { is_expected.to validate_presence_of(:transacted_at) }
    it { is_expected.to validate_numericality_of(:from_amount) }
    it { is_expected.to validate_numericality_of(:to_amount) }
    it { is_expected.to validate_numericality_of(:fee_amount) }
    it { is_expected.to validate_numericality_of(:exchange_rate) }
  end
end
