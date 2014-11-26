require 'sinatra/base'

class FakePepperjamApi < Sinatra::Base
  get '/400/publisher/advertiser' do
    json_response 200, 'json_400_response.json'
  end

  get '/3/publisher/creative/coupon' do
    json_response 200, 'coupons3_response.json'
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end
end