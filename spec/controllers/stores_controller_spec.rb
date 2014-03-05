require 'spec_helper'

describe StoresController do

  describe "GET index" do
    before {

      store = Array.new
      coupon = Array.new

      (1..20).each do |i|
        store[i] = Fabricate(:store)
        coupon[i] = Fabricate(:coupon, store_id: store[i].id, end_date: Time.now + i.hour )
      end
    }
    
    it "sets @stores to all stores" do
      get :index
      expect(assigns(:stores).count).to eq(20)
    end

    it "sets @stores_featured to stores with coupons" do
      get :index
      expect(assigns(:stores_featured).count).to eq(12)
    end

    it "sets @store_array" do

      get :index
      expect(assigns(:store_array).count).to eq(20)
    end
  end

  describe "GET show" do
    let!(:store1) { Fabricate(:store) }
    let!(:coupon1) { Fabricate(:coupon, code: 'now', store_id: store1.id, end_date: Time.now + 2.hour ) }
    let!(:coupon2) { Fabricate(:coupon, code: nil, store_id: store1.id, end_date: Time.now + 1.hour ) }
    before { get :show, id: store1.id }

    it "finds store and sets @store" do
      expect(assigns(:store)).to eq(store1)
    end

    it "sets current @coupons for store expiring ones first" do
      expect(assigns(:coupons)).to eq([coupon2,coupon1])
    end

    it "sets @coupon_codes" do
      expect(assigns(:coupon_codes)).to eq([coupon1])
    end

    it "sets @coupon_offers" do
      expect(assigns(:coupon_offers)).to eq([coupon2])
    end
  end
end
