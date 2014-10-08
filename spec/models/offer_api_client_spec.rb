require 'spec_helper'
require 'rails_helper'

RSpec.describe OfferApiClient, type: :model do

  describe '#request' do

    context 'when preparing a request data' do

      subject { OfferApiClient.new('some_uid') }

      it 'should create a hashkey' do
        mock_server_response({code: 500})
        expect_any_instance_of(OfferApiClient).to receive(:sing_request)
        subject.request        
      end

      it 'should call prepare_url twice' do
        mock_server_response({code: 500})
        expect_any_instance_of(OfferApiClient).to receive(:prepare_url).twice.and_return("")
        subject.request        
      end

      it 'should validate data' do
        offer_client = OfferApiClient.new('some_uid', nil, 'wrong_page')
        expect(offer_client.request).to be false
        expect(offer_client.errors.size).to eq(1)
        expect(offer_client.errors.messages.has_key?(:page)).to be true
      end

    end

    context 'when sending a request' do

      subject { OfferApiClient.new('some_uid') }

      it 'should call a Fiber server' do
        mock_server_response({expect_call: true})
        subject.request
      end

    end

    context 'when receiving data' do

      context 'with error should return false and object with erorrs in case of' do

        subject { OfferApiClient.new('some_uid') }

        it 'not successfull code' do
          mock_server_response({code: 500})

          expect(subject.request).to be false
          expect(subject.errors.full_messages.size).to eq(1)
        end

        it 'fake response sign' do
          mock_server_response({sign: "WrongSign", return_sign: true})

          expect(subject.request).to be false
          expect(subject.errors.full_messages.first).to eq("response not valid")
        end

      end  

      context 'without error' do

        subject { OfferApiClient.new('some_uid') }

        it 'should return true and fill offers variable' do
          mock_server_response({return_sign: true})
          expect(subject.request).to be true
          expect(subject.results.size).to eq(3)
        end

      end

    end

  end

end