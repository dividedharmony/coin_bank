# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinBank::User, type: :model do
  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
  end
end
