# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoinbaseIntegration::Client, vcr: { record: :none } do
  let(:client) { described_class.new }

  describe '#accounts' do
    subject { client.accounts(starting_after_uuid: starting_after_uuid) }

    context 'if starting_after is nil' do
      let(:starting_after_uuid) { nil }

      context 'if server response is not success' do
        before do
          mock_headers = instance_double(
            CoinbaseIntegration::ApiHeaders,
            to_h: {
              'FAKE-HEADER' => 'Fake value'
            }
          )
          expect(CoinbaseIntegration::ApiHeaders).to receive(:new) { mock_headers }
        end

        it 'returns a Failure result' do
          expect(subject).to be_failure
          expect(subject.message).to eq('The access token is invalid')
        end
      end

      context 'if server response is success' do
        it 'returns a Success result' do
          expect(subject).to be_success
          resource_obj = subject.value!
          expect(resource_obj.data.size).to eq(25)
          expect(resource_obj.data.first).to include(
            'id' => '2fc10e3c-c89f-58dd-a70c-01b652af5c69',
            'type' => 'wallet',
            'name' => 'TRU Wallet'
          )
          expect(resource_obj.data.last).to include(
            'id' => 'ffe6501b-71b3-5e65-b031-887893b70e05',
            'type' => 'wallet',
            'name' => 'GTC Wallet'
          )
        end
      end
    end

    context 'if starting_after is present' do
      let(:starting_after_uuid) { '83f061d1-5152-534f-8415-87082a5ab086' }

      context 'if server response is not success' do
        before do
          mock_headers = instance_double(
            CoinbaseIntegration::ApiHeaders,
            to_h: {
              'FAKE-HEADER' => 'Fake value'
            }
          )
          expect(CoinbaseIntegration::ApiHeaders).to receive(:new) { mock_headers }
        end

        it 'returns a Failure result' do
          expect(subject).to be_failure
          expect(subject.message).to eq('The access token is invalid')
        end
      end

      context 'if server response is success' do
        it 'returns a Success result' do
          expect(subject).to be_success
          resource_obj = subject.value!
          expect(resource_obj.data.size).to eq(85)
          expect(resource_obj.data.first).to include(
            'id' => '966746cb-62a3-5b8f-b268-f4b8732d59e2',
            'type' => 'wallet',
            'name' => 'MKR Wallet'
          )
          expect(resource_obj.data.last).to include(
            'id' => 'RNDR',
            'type' => 'wallet',
            'name' => 'RNDR Wallet'
          )
        end
      end
    end
  end

  describe '#transactions' do
    let(:account_uuid) { '966746cb-62a3-5b8f-b268-f4b8732d59e2' }

    subject do
      client.transactions(account_uuid, starting_after_uuid: starting_after_uuid)
    end

    context 'if starting_after is nil' do
      let(:starting_after_uuid) { nil }

      context 'if server response is not success' do
        before do
          mock_headers = instance_double(
            CoinbaseIntegration::ApiHeaders,
            to_h: {
              'FAKE-HEADER' => 'Fake value'
            }
          )
          expect(CoinbaseIntegration::ApiHeaders).to receive(:new) { mock_headers }
        end

        it 'returns a Failure result' do
          expect(subject).to be_failure
          expect(subject.message).to eq('The access token is invalid')
        end
      end

      context 'if server response is success' do
        it 'returns a Success result' do
          expect(subject).to be_success
          resource_obj = subject.value!
          expect(resource_obj.data.size).to eq(25)
          expect(resource_obj.data.first).to include(
            'id' => 'b46dacc9-7387-5abe-a3e5-3a9e057b1a69',
            'type' => 'trade',
            'amount' => {
              'amount' => '0.00528336',
              'currency' => 'MKR'
            }
          )
          expect(resource_obj.data.last).to include(
            'id' => '381ccf7f-760e-5eab-9989-3ef43a43c34a',
            'type' => 'trade',
            'amount' => {
              'amount' => '0.00362231',
              'currency' => 'MKR'
            }
          )
        end
      end
    end

    context 'if starting_after is present' do
      let(:starting_after_uuid) { '381ccf7f-760e-5eab-9989-3ef43a43c34a' }

      context 'if server response is not success' do
        before do
          mock_headers = instance_double(
            CoinbaseIntegration::ApiHeaders,
            to_h: {
              'FAKE-HEADER' => 'Fake value'
            }
          )
          expect(CoinbaseIntegration::ApiHeaders).to receive(:new) { mock_headers }
        end

        it 'returns a Failure result' do
          expect(subject).to be_failure
          expect(subject.message).to eq('The access token is invalid')
        end
      end

      context 'if server response is success' do
        it 'returns a Success result' do
          expect(subject).to be_success
          resource_obj = subject.value!
          expect(resource_obj.data.size).to eq(3)
          expect(resource_obj.data.first).to include(
            'id' => '35594d68-6df5-5b98-938e-2cdbb8c219bc',
            'type' => 'trade',
            'amount' => {
              'amount' => '0.00166782',
              'currency' => 'MKR'
            }
          )
          expect(resource_obj.data.last).to include(
            'id' => 'b9ee9527-84a2-5fa0-85bf-59a06b9de0db',
            'type' => 'trade',
            'amount' => {
              'amount' => '0.00124939',
              'currency' => 'MKR'
            }
          )
        end
      end
    end
  end

  describe '#buys' do
    let(:account_uuid) { '265d3b77-0adb-5c47-ad35-6572578475a5' }

    subject do
      client.buys(account_uuid, starting_after_uuid: starting_after_uuid)
    end

    context 'if starting_after is nil' do
      let(:starting_after_uuid) { nil }

      context 'if server response is not success' do
        before do
          mock_headers = instance_double(
            CoinbaseIntegration::ApiHeaders,
            to_h: {
              'FAKE-HEADER' => 'Fake value'
            }
          )
          expect(CoinbaseIntegration::ApiHeaders).to receive(:new) { mock_headers }
        end

        it 'returns a Failure result' do
          expect(subject).to be_failure
          expect(subject.message).to eq('The access token is invalid')
        end
      end

      context 'if server response is success' do
        it 'returns a Success result' do
          expect(subject).to be_success
          resource_obj = subject.value!
          expect(resource_obj.data.size).to eq(2)
          expect(resource_obj.data.first).to include(
            'id' => 'b92b1981-9b4a-562f-bcf0-41c8d3a71e19',
            "amount" => {
              "amount"=>"287.00105717",
              "currency"=>"DAI"
            },
            "fee" => {
              "amount"=>"11.51",
              "currency"=>"USD"
            },
            "subtotal" => {
              "amount"=>"288.49",
              "currency"=>"USD"
            },
            "total" => {
              "amount"=>"300.00",
              "currency"=>"USD"
            }
          )
          expect(resource_obj.data.last).to include(
            'id' => '3b7e8af2-68da-58ce-bfb8-3cb3936a6847',
            "amount" => {
              "amount"=>"47.78200966",
              "currency"=>"DAI"
            },
            "fee" => {
              "amount"=>"1.99",
              "currency"=>"USD"
            },
            "subtotal" => {
              "amount"=>"48.01",
              "currency"=>"USD"
            },
            "total" => {
              "amount"=>"50.00",
              "currency"=>"USD"
            }
          )
        end
      end
    end

    context 'if starting_after is present' do
      let(:starting_after_uuid) { '92c6ca6b-f8fa-568f-b058-1d3ecbe8d11d' }

      context 'if server response is not success' do
        before do
          mock_headers = instance_double(
            CoinbaseIntegration::ApiHeaders,
            to_h: {
              'FAKE-HEADER' => 'Fake value'
            }
          )
          expect(CoinbaseIntegration::ApiHeaders).to receive(:new) { mock_headers }
        end

        it 'returns a Failure result' do
          expect(subject).to be_failure
          expect(subject.message).to eq('The access token is invalid')
        end
      end

      context 'if server response is success' do
        it 'returns a Success result' do
          expect(subject).to be_success
          resource_obj = subject.value!
          expect(resource_obj.data.size).to eq(2)
          expect(resource_obj.data.first).to include(
            'id' => '0fc184bc-c8bf-54fc-a0d2-576c315df22d',
            "amount" => {
              "amount"=>"95.82348955",
              "currency"=>"DAI"
            },
            "fee" => {
              "amount"=>"3.84",
              "currency"=>"USD"
            },
            "subtotal" => {
              "amount"=>"96.16",
              "currency"=>"USD"
            },
            "total" => {
              "amount"=>"100.00",
              "currency"=>"USD"
            }
          )
          expect(resource_obj.data.last).to include(
            'id' => '3b7e8af2-68da-58ce-bfb8-3cb3936a6847',
            "amount" => {
              "amount"=>"47.78200966",
              "currency"=>"DAI"
            },
            "fee" => {
              "amount"=>"1.99",
              "currency"=>"USD"
            },
            "subtotal" => {
              "amount"=>"48.01",
              "currency"=>"USD"
            },
            "total" => {
              "amount"=>"50.00",
              "currency"=>"USD"
            }
          )
        end
      end
    end
  end

  describe '#trades' do
    subject { client.trades }

    context 'if server response is not success' do
      before do
        mock_headers = instance_double(
          CoinbaseIntegration::ApiHeaders,
          to_h: {
            'FAKE-HEADER' => 'Fake value'
          }
        )
        expect(CoinbaseIntegration::ApiHeaders).to receive(:new) { mock_headers }
      end

      it 'returns a Failure result' do
        expect(subject).to be_failure
        expect(subject.message).to eq('The access token is invalid')
      end
    end

    context 'if server response is success' do
      it 'returns a Success result' do
        expect(subject).to be_success
        resource_obj = subject.value!
        expect(resource_obj.data.size).to eq(3)
        expect(resource_obj.data.first).to include(
          'id' => 'b33f363b-6783-5a43-8ef0-6a128d2224f8',
          'input_amount' => {
            'amount' => '29.96895217',
            'currency' => 'DAI'
          },
          'output_amount' => {
            'amount' => '0.00048516',
            'currency' => 'BTC'
          }
        )
        expect(resource_obj.data.last).to include(
          'id' => '1ed7e1fd-5f0a-57cf-b6c6-de6886cc4949',
          'input_amount' => {
            'amount' => '14.99744294',
            'currency' => 'DAI'
          },
          'output_amount' => {
            'amount' => '0.00028741',
            'currency' => 'BTC'
          }
        )
      end
    end
  end
end
