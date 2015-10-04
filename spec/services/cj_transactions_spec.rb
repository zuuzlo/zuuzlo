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
    context "id is not existing coupon & has store" do
      it "creates new coupons"
      it "adds enddate if it does not exist"
      it "adds coupon to categories"
      it "adds coupon to ctypes"
    end
  end
end
