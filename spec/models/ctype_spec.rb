require_relative '../spec_helper'

describe Ctype do
  it { should have_and_belong_to_many(:coupons) }
  it { should validate_presence_of(:name) }

  let(:free) { Fabricate(:ctype, name: "free") }
  let(:cheap) { Fabricate(:ctype, name: "cheap") }

  describe "with_coupons" do
    it "should return all categories with coupons end_date after time now with name in alphabit order" do
      coupon = Array.new
      (1..3).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now + i.hour )
        coupon[i].ctypes << free
        coupon[i].ctypes << cheap
      end 
      expect(Ctype.with_coupons).to eq([cheap, free])
    end

    it "should return only category with coupons not out of date" do
      coupon = Array.new
      (1..3).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now - i.hour )
        coupon[i].ctypes << free
      end

      (4..5).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now + i.hour )
        coupon[i].ctypes << cheap
      end  
      expect(Ctype.with_coupons).to eq([cheap])
    end 

  end

end