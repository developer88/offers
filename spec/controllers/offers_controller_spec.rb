require 'spec_helper'
require 'rails_helper'

RSpec.describe OffersController, type: :controller do

  describe "GET index without params" do

    subject { get :index }

    it "renders the index template" do
      expect(subject).to render_template("index")
    end

  end

  describe "GET index with" do

    context 'valid params' do

      before do
        allow_any_instance_of(OfferApiClient).to receive(:request).and_return(true)
      end

      subject { get :index, page: 1, uid: 'player1', search: 1 }

      context 'should return offers from Fiber server' do

        before do       
          results = [
            {
              "title" => " Tap  Fish",
              "thumbnail" => { "lowres" =>  "http://cdn.sponsorpay.com/assets/1808/icon175x175- 2_square_60.png" },
              "payout" => "90"
            }
          ]
          allow_any_instance_of(OfferApiClient).to receive(:results).and_return(results)
        end        

        it 'assigns @offers' do    
          subject      
          expect(assigns(:offers).size).to be > 0
        end

        it 'renders the index template' do
          expect(subject).to render_template("index")
        end

      end

      context 'should not return offers from Fiber server' do

        subject { get :index, page: 1, uid: 'player1', search: 1 }

        before do
          allow_any_instance_of(OfferApiClient).to receive(:results).and_return([])
        end

        it "renders the index template" do          
          expect(subject).to render_template("index")
        end

        it "not assigns @offers" do      
          subject    
          expect(assigns(:offers).size).to eq(0)
        end

      end
      
    end

    context 'invalid params' do

      context 'should raise a validation error' do

        subject { get :index, page: 0, search: 1 }

        it 'assigns flash.error' do
          expect(subject.request.flash[:errors]).to_not be_nil
          expect(subject.request.flash[:errors].size).to eq(2)
        end

        it "renders the index template" do
          expect(subject).to render_template("index")
        end

      end

      context 'should raise an error from Fiber server' do

        before do
          mock_server_response({code: 400, data: {code: 'Some code', message: 'Some error'}.to_json})
        end

        subject { get :index, page: 1, search: 1, uid: 'player1' }

        it 'assigns flash.error' do
          expect(subject.request.flash[:errors]).to_not be_nil
          expect(subject.request.flash[:errors].size).to eq(1)
        end

        it "renders the index template" do
          expect(subject).to render_template("index")
        end

      end    

    end

  end

end