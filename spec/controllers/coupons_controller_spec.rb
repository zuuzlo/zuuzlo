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
       
      expect(assigns(:coupon_codes)).to eq(1)
    end

    it "set @coupon_offers" do
      
      expect(assigns(:coupon_offers)).to eq(1)
    end
  end

  describe "POST toggle_favorite" do
    let!(:store1) { Fabricate(:store) }
    let!(:coupon1) { coupon1 = Fabricate(:coupon, store_id: store1.id) }
    context "with authenticated user" do
      before do
        set_current_user
        request.env["HTTP_REFERER"] = store_path(store1) 
      end
      after { current_user.coupons.clear }

      it "sets @coupon" do
        post :toggle_favorite, { id: coupon1.id, coupon_id: coupon1.id }
        expect(assigns(:coupon)).to eq(coupon1)
      end

      context "coupon not in favorites" do
        before do
          post :toggle_favorite, { id: coupon1.id, coupon_id: coupon1.id }
        end

        it "adds coupon to users coupons (favorite)" do
          expect(current_user.coupons.count).to eq(1)
        end

        it "set flash success" do
          expect(flash[:success]).to be_present
        end
      end
      
      context "coupon in favorites" do
        before do
          current_user.coupons << coupon1
          post :toggle_favorite, { id: coupon1.id, coupon_id: coupon1.id }
        end

        it "removes coupon from users" do
          expect(current_user.coupons.count).to eq(0)
        end

        it "set flash success" do
          expect(flash[:success]).to be_present
        end
      end
    end
  end
end
