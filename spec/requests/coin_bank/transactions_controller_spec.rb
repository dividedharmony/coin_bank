# frozen_string_literal: true

require "dry/monads"
require "rails_helper"

RSpec.describe CoinBank::TransactionsController, type: :request do
  include Dry::Monads[:result]

  describe "GET #new" do
    subject do
      get "/transactions/new"
      response
    end

    context "if user is not signed in" do
      it { is_expected.to redirect_to("/") }
    end

    context "if user is signed in" do
      before do
        sign_in_as! create(:user)
      end

      it "builds a new currency" do
        subject
        expect(assigns[:transaction]).to be_instance_of(CoinBank::Transaction)
        expect(assigns[:transaction]).not_to be_persisted
      end
    end
  end

  describe "POST #create" do
    subject do
      post "/transactions", params: params
      response
    end

    let(:params) do
      {
        coin_bank_transaction: "Placeholder value"
      }
    end

    context "if user is not signed in" do
      it { is_expected.to redirect_to("/") }
    end

    context "if user is signed in" do
      let(:user) { create(:user) }

      before do
        sign_in_as! user
      end

      context "if command cannot create a transaction" do
        it "builds a new transaction" do
          expect(CoinBank::CreateTransaction).
            to receive(:call).
            with(current_user: user, params: hash_including(**params)).
            and_return(Dry::Monads::Failure("That's no good!"))
          expect(subject).to redirect_to("/transactions/new")
          expect(flash[:error]).to eq("That's no good!")
        end
      end

      context "if command can create a transaction" do
        let(:transaction) { create(:transaction) }

        it "builds a new transaction" do
          expect(CoinBank::CreateTransaction).
            to receive(:call).
            with(current_user: user, params: hash_including(**params)).
            and_return(Dry::Monads::Success(transaction))
          expect(subject).to redirect_to("/transactions")
          expect(flash[:success]).to eq("Successfully recorded transaction!")
        end
      end
    end
  end

  describe "GET #index" do
    subject do
      get "/transactions"
      response
    end

    let!(:transaction) { create(:transaction) }

    context "if user is not signed in" do
      it { is_expected.to redirect_to("/") }
    end

    context "if user is signed in" do
      let(:user) { create(:user) }

      before do
        sign_in_as! user
      end

      context "if the user does not have any transactions" do
        it "does not display any transactions" do
          subject
          expect(assigns[:transactions]).to be_empty
        end
      end

      context "if the user has at least one transaction" do
        let!(:transaction) { create(:transaction, user: user) }
        let!(:transaction_for_other_user) { create(:transaction) }

        it "displays all and only the transactions for that user" do
          subject
          expect(assigns[:transactions]).to include(transaction)
          expect(assigns[:transactions]).not_to include(transaction_for_other_user)
        end
      end
    end
  end
end
