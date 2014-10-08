module ServerResponseMockHelper

	def mock_server_response(options = {})
		options = {
			code: 200,
			expect_call: false,
			return_sign: false,
			data: {offers: [1,2,3]}.to_json
		}.merge(options)

		options[:sign] = Digest::SHA1.hexdigest(options[:data] + "#{Settings.apikey}") unless options.has_key?(:sign)
		
        net_http_resp = Net::HTTPResponse.new(1.0, options[:code], "Some HTTP Code message")
        net_http_resp.add_field 'X-Sponsorpay-Response-Signature', options[:sign] if options[:return_sign]
        allow(net_http_resp).to receive(:body).and_return(options[:data])
        allow(Net::HTTP).to receive(:get_response).and_return(net_http_resp) unless options[:expect_call]
        expect(Net::HTTP).to receive(:get_response).and_return(net_http_resp) if options[:expect_call]
	end

end