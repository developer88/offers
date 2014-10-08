require 'net/http'
require 'digest/sha1'
require 'active_model'

class OfferApiClient
	include ActiveModel::Validations

	attr_reader :results
	attr_accessor :uid, :pub0, :page

	validates :page, numericality: { only_integer: true , greater_than: 0}
	validates :uid, presence: true

	def initialize(uid, pub0 = nil, page = 1)
		@uid = uid
		@pub0 = pub0
		@page = page.to_i
	end

	def request
		return false unless valid?
		reset_params

		url = "http://api.sponsorpay.com/feed/v1/offers.json?" + prepare_url
		resp = Net::HTTP.get_response(URI.parse(url))
		data = JSON.parse(resp.body)

		unless resp.code.to_i == 200
			errors[:base] << data["message"]
			return false
		end
		unless response_valid?(resp)
			errors[:base] << "response not valid"
			return false
		end

		@results = data['offers']
		true
	end

	private

		def response_valid?(resp)
			resp['X-Sponsorpay-Response-Signature'] == Digest::SHA1.hexdigest(resp.body.to_s + "#{Settings.apikey}")
		end

		def prepare_url
			@params.map{|k,v| "#{k}=#{v}"}.join("&") 
		end

		def sing_request
			Digest::SHA1.hexdigest prepare_url + "&#{Settings.apikey}"
		end

		def reset_params
			@params = {
				appid: Settings.appid,
				device_id: Settings.device_id,			
				id: Settings.ip,
				locale: Settings.locale,				
				offer_types: Settings.offer_types,
				page: page,
				ps_time: (Time.now - 1.day).to_i,
				pub0: pub0,
				timestamp: Time.now.to_i,
				uid: uid
			}
			@params[:hashkey] = sing_request
			@results = []
		end

end	