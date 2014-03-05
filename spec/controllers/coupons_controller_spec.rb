require 'spec_helper'

describe CouponsController do
  describe "GET search" do
    let!(:coupon1) { coupon1 = Fabricate(:coupon, code: 'now', description: 'good car', end_date: Time.now + 1.hour ) }
    let!(:coupon2) { coupon2 = Fabricate(:coupon, code: nil, description: 'fast car', end_date: Time.now + 1.hour ) }
    let!(:coupon3) { coupon3 = Fabricate(:coupon, code: nil, description: 'fast dog', end_date: Time.now + 1.hour ) }
    before { get :search, search_term: 'car' }

    it "set @coupons where coupons description has search term" do
      
      expect(assigns(:coupons)).to eq([coupon1, coupon2])
    end

    it "set @term to search term" do
      
      expect(assigns(:term)).to eq('car')
    end

    it "set @coupon_codes" do
       
      expect(assigns(:coupon_codes)).to eq([coupon1])
    end

    it "set @coupon_offers" do
      
      expect(assigns(:coupon_offers)).to eq([coupon2])
    end
  end
end
