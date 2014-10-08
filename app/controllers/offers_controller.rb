class OffersController < ApplicationController

	def index
		@offer_client = OfferApiClient.new(offer_params[:uid], offer_params[:pub0], offer_params[:page])
		return unless offer_params[:search]
		flash[:errors] = @offer_client.request == false ? @offer_client.errors.full_messages : nil
		@offers = @offer_client.results	
	end

	private

		def offer_params
			params.permit(:uid, :pub0, :page, :search)
		end

end
