require 'sinatra/base'

class FakeCjApi < Sinatra::Base
  get '/v3/advertiser-lookup' do
    pg = params['page-number'].to_i
    #require 'pry'; binding.pry
    
    case pg
    when 1
      xml_response 200, 'cj_stores_pg1_response.xml'
    when 2
      #require 'pry'; binding.pry
      xml_response 200, 'cj_stores_pg2_response.xml'
    when 3
      xml_response 200, 'cj_stores_pg3_response.xml'
    else
      xml_response 200, 'cj_stores_pg3_response.xml'
    end
  end

  get '/v2/link-search' do
    advertiser_id = params['advertiser-ids'].to_i
    pg = params['page-number']
    link_type = params['link-type']  
    
    if link_type = 'banner'
      case advertiser_id
      when 100
        xml_response 200, 'cj_store_banner_response.xml'
      when 999
        xml_response 200, 'cj_store_no_banner_response.xml'
      else
        xml_response 200, 'cj_multi_store_banner_response.xml'
      end
    else
      case pg
      when 1
        xml_response 200, 'cj_coupons_pg1_response.xml'
      when 2
        xml_response 200, 'cj_coupons_pg2_response.xml'
      when 3
        xml_response 200, 'cj_coupons_pg3_response.xml'
      end
    end
  end

  private

  def xml_response(response_code, file_name)
    content_type 'application/xml; charset=UTF-8'
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/' + file_name, 'rb').read
  end
end