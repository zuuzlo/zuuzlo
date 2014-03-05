require 'spec_helper'

describe CtypesController do

  describe "GET show" do
    let!(:ctype1) { Fabricate(:ctype) }
    before { get :show, id: ctype1.id }

    it "sets @ctype" do
      expect(assigns(:ctype)).to eq(ctype1)
    end

    it "sets @coupons that are not expired in @category" do
      coupon = Array.new
      (1..3).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now - i.hour )
        coupon[i].ctypes << ctype1
      end

      (4..5).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now + i.hour )
        coupon[i].ctypes << ctype1
      end 
      get :show, id: ctype1.id 
      expect(assigns(:coupons)).to eq([coupon[4], coupon[5]])
    end

    it "sets @coupon_codes" do
      coupon1 = Fabricate( :coupon, code: 'now', end_date: Time.now + 1.hour )
      coupon1.ctypes << ctype1
      get :show, id: ctype1.id 
      expect(assigns(:coupon_codes)).to eq([coupon1])
    end

    it "sets @coupon_offers" do
      coupon1 = Fabricate( :coupon, code: nil, end_date: Time.now + 1.hour )
      coupon1.ctypes << ctype1
      get :show, id: ctype1.id 
      expect(assigns(:coupon_offers)).to eq([coupon1])
    end
  end
end