require 'spec_helper'
require "recursive_open_struct"

describe CjTransactions do
  describe "load_cj_stores" do
    context "new stores only" do
      before do
        CjTransactions.load_cj_stores
      end

      it "should load 2 pgs 10 stores" do 
        expect(Store.count).to eq(10)
      end
     
      it "first store is active" do
        expect(Store.first.active_commission).to be_true
      end

      it "last store is not active" do
        expect(Store.last.active_commission).to be_false
      end
    end

    context "duplicate stores with one new" do
      store_ids = ["767685", "859514", "867296", "904879" ]
      
      (0..3).each do | x |
        let("store#{x}".to_s) { Fabricate(:store, id_of_store: store_ids[x], active_commission: true ) }
      end

      before do
        CjTransactions.load_cj_stores
      end

      it "should have 10 stores" do
        expect(Store.count).to eq(10)
      end

      it "store 4 is not active" do
        expect(Store.find(4).active_commission).to be_true
      end

      it "new store id should be 893475" do
        expect(Store.find(4).id_of_store).to eq(893475)
      end
    end
  end

  describe "find_commission" do
    context "action is hash with default string" do
      let(:data) { {"name"=>"Sale", "type"=>"sale", "id"=>"5195", "commission"=>{"default"=>"10.00%"}} }
      it "should return 10.0" do
        expect(CjTransactions.find_commission(data)).to eq(10.0)
      end
    end

    context "action is hash with commission as hash with %" do
      let(:data) { {"name"=>"Sale", "type"=>"sale", "id"=>"4170", "commission"=>{"default"=>{"type"=>"item-level", "__content__"=>"10.00%"}}} }
      it "should return 10.0" do
        expect(CjTransactions.find_commission(data)).to eq(10.0)
      end
    end

    context "action is hash with commission as hash no %" do
      let(:data) { {"name"=>"Sale", "type"=>"sale", "id"=>"4170", "commission"=>{"default"=>{"type"=>"item-level", "__content__"=>"USD 95.00"}}} }
      it "should return 10.0" do
        expect(CjTransactions.find_commission(data)).to eq(0.0)
      end
    end
  
    context "action is array with default string" do
      let(:data) { [{"name"=>"Gift Certificate Purchase Item Based", "type"=>"advanced sale", "id"=>"348384", "commission"=>{"default"=>"15.00%"}}, {"name"=>"Mobile - item", "type"=>"advanced sale", "id"=>"360841", "commission"=>{"default"=>"15.00%"}}, {"name"=>"Specials - Purchase", "type"=>"sale", "id"=>"361463", "commission"=>{"default"=>"3.00%"}}] }
      it "should return 10.0" do
        expect(CjTransactions.find_commission(data)).to eq(15.0)
      end
    end
  end

  describe "find_image" do
    
    context "image is found" do
      let(:store1) { Fabricate(:store, id_of_store: 100, active_commission: true ) }
      
      it "returns image link for store" do
        expect(CjTransactions.find_image(store1.id_of_store)).to eq("http://www.tqlkg.com/image-6181211-5643705-1401823228000")
      end
    end

    context "image is not found" do
      let(:store1) { Fabricate(:store, id_of_store: 999, active_commission: true ) }
      
      it "returns generic image for store" do
        expect(CjTransactions.find_image(store1.id_of_store)).to eq("#{Rails.root}/images/coming_soon.jpg")
      end
    end
  end

  describe "cj_update_coupons" do
    
    (1..32).each do |i|
      let!("category#{i}".to_s) { Fabricate(:category, ls_id: i) }
    end

    (1..31).each do |i|
      let!("type#{i}".to_s) { Fabricate(:ctype, ls_id: i) }
    end
    
    context "id is not existing coupon & has store" do
      stores = [1845109, 3811852, 2458053, 4018060]
      stores.each_with_index do | store, i |
        let!("store#{i}".to_s) { Fabricate(:store, id_of_store: store , active_commission: true ) }
      end

      before do
        CjTransactions.cj_update_coupons
      end
      
      it "creates new coupons and gets multiple pages" do
        expect(Coupon.count).to eq(15)
      end

      it "creates a start date if it doesn't have one" do
        expect(Coupon.first.start_date.strftime("%m/%d/%Y")).to eq(Time.now.strftime("%m/%d/%Y"))
      end

      it "coupon start date if it has one" do
        expect(Coupon.last.start_date).to eq("Sun, 04 Oct 2015 19:14:00 CDT -05:00")
      end

      it "adds end date if it does not exist" do
        t = Time.now + 3.years
        expect(Coupon.first.end_date.strftime("%m/%d/%Y")).to eq(t.strftime("%m/%d/%Y"))
      end

      it "coupon end date if it has one" do
        expect(Coupon.last.end_date).to eq("Mon, 19 Oct 2015 08:59:00 CDT -05:00")
      end

      it "adds coupon to categories" do
        expect(Coupon.last.categories).to eq([category6])
      end

      it "adds coupon to ctypes" do
        expect(Coupon.first.ctypes).to eq([type11])
      end
    end

    context "doesn't add coupon if it exists" do
      stores = [1845109, 3811852, 2458053, 4018060]
      stores.each_with_index do | store, i |
        let!("store#{i}".to_s) { Fabricate(:store, id_of_store: store , active_commission: true ) }
      end
      
      let!(:coupon1) { Fabricate(:coupon, id_of_coupon: 11430366, coupon_source_id: 3 ) }
      
      before do
        CjTransactions.cj_update_coupons
      end

      it "coupon one is not from test list" do
        expect(Coupon.first).to eq(coupon1)
      end
    end

    context "no store for coupon" do
      stores = [3811852, 2458053, 4018060]
      #1845109
      stores.each_with_index do | store, i |
        let!("store#{i}".to_s) { Fabricate(:store, id_of_store: store , active_commission: true ) }
      end

      before do
        CjTransactions.cj_update_coupons
      end

      it "tries to loads store before saving coupon" do
        expect(Store.find(Coupon.find(3).store_id).id_of_store).to eq(1845109)
      end
    end
  end
end
