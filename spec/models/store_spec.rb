require 'spec_helper'

describe Store do
  it { should have_many(:coupons) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:id_of_store) }

  let(:store1) { Fabricate(:store, name: 'store1') }
  let(:store2) { Fabricate(:store, name: 'store2') }

  describe "with_coupons" do
    it "should return all stores with coupons end_date after time now" do
      coupon = Array.new
      (1..3).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now + i.hour, store_id: store1.id )
      end 
        expect(Store.with_coupons).to eq([store1])
    end

    it "should return only store with coupons not out of date" do
      coupon = Array.new
      (1..3).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now - i.hour, store_id: store1.id )
      end

      (4..5).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now + i.hour, store_id: store2.id )
      end  
      expect(Store.with_coupons).to eq([store2])
    end
  end
end