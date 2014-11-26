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

    it "sets number of codes_count" do
      expect(assigns(:codes_count)).to eq(1)
    end

    it "sets number of offers_count" do
      expect(assigns(:offers_count)).to eq(1)
    end
  end

  describe "POST save_store" do
    let!(:store1) { Fabricate(:store) }
    context "with authenticated user" do
      before do
        set_current_user
        request.env["HTTP_REFERER"] = store_path(store1)
        post :save_store, { id: store1.id, store_id: store1.id}
      end

      it "sets @store" do
        expect(assigns(:store)).to eq(store1)
      end

      it "adds store to users stores (favorite)" do
        expect(current_user.stores.count).to eq(1)
      end

      it "set flash success" do
        expect(flash[:success]).to be_present
      end
    end

    context "without authenticated user" do
      it_behaves_like "require_sign_in" do
        let(:action) { post :save_store, { id: store1.id, store_id: store1.id} }
      end
    end
  end

  describe "POST remove_store" do
    let!(:store1) { Fabricate(:store) }
    context "with authenticated user" do
      before do
        set_current_user
        current_user.stores << store1
        request.env["HTTP_REFERER"] = store_path(store1)
        post :remove_store, { id: store1.id, store_id: store1.id}
      end

      it "sets @store" do
        expect(assigns(:store)).to eq(store1)
      end

      it "adds store to users stores (favorite)" do
        expect(current_user.stores.count).to eq(0)
      end

      it "set flash success" do
        expect(flash[:success]).to be_present
      end
    end

    context "without authenticated user" do
      it_behaves_like "require_sign_in" do
        let(:action) { post :remove_store, { id: store1.id, store_id: store1.id} }
      end
    end
  end
end
