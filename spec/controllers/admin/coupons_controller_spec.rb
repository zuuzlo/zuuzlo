require 'spec_helper'

describe Admin::CouponsController do
  describe "GET delete_coupons" do
    context "coupons to delete" do
      let!(:coupon1) { coupon1 = Fabricate(:coupon, code: 'BUYNOW', description: 'good car', end_date: Time.now - 2.day ) }
      let!(:coupon2) { coupon2 = Fabricate(:coupon, code: nil, description: 'fast car', end_date: Time.now - 3.day ) }
      let!(:coupon3) { coupon3 = Fabricate(:coupon, code: nil, description: 'fast dog', end_date: Time.now + 1.hour ) }
      
      before do 
        set_admin_user
        get :delete_coupons
      end

      it "have 1 coupon of the 3 left" do
        expect(Coupon.count).to eq(1)
      end

      it "sets flash to success" do
        expect(flash[:success]).to be_present
      end

      it "set flash message" do
        expect(flash[:success]).to eq("Deleted 2 coupons.")
      end

      it "redirect to admin page" do
        expect(response).to redirect_to admin_coupons_path
      end 
    end
  end
end