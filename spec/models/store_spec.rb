require 'spec_helper'

describe Store do
  it { should have_many(:coupons) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:id_of_store) }
  it { should validate_uniqueness_of(:id_of_store) }
  it { should have_and_belong_to_many(:users) }
  it { should have_many(:activities) }

  let(:store1) { Fabricate(:store, name: 'store1', active_commission: true) }
  let(:store2) { Fabricate(:store, name: 'store2', active_commission: true) }
  let(:store3) { Fabricate(:store, name: 'store2', active_commission: false) }

  describe "with_coupons" do
    it "should return all stores with coupons end_date after time now and have active commmission" do
      coupon = Array.new
      coupon3 = Array.new
      (1..3).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now + i.hour, store_id: store1.id )
        coupon3[i] = Fabricate(:coupon, title: "coupon3#{i}", end_date: Time.now + i.hour, store_id: store3.id )
      end 
        expect(Store.with_coupons).to eq([store1])
    end

    it "should return only store with coupons not out of date" do
      coupon = Array.new
      coupon3 = Array.new
      (1..3).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now - i.hour, store_id: store1.id )
      end

      (4..5).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now + i.hour, store_id: store2.id )
        coupon3[i] = Fabricate(:coupon, title: "coupon3#{i}", end_date: Time.now + i.hour, store_id: store3.id )
      end  
      expect(Store.with_coupons).to eq([store2])
    end
  end
end