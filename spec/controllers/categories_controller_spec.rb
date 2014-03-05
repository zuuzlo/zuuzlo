require 'spec_helper'

describe CategoriesController do

  describe "GET show" do
    let!(:cat1) { Fabricate(:category) }
    #before { get :show, id: cat1.id }

    it "sets @category" do
      get :show, id: cat1.id
      expect(assigns(:category)).to eq(cat1)
    end

    it "sets @coupons that are not expired in @category" do
      coupon = Array.new
      (1..3).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now - i.hour )
        coupon[i].categories << cat1
      end

      (4..5).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now + i.hour )
        coupon[i].categories << cat1
      end 
      get :show, id: cat1.id
      expect(assigns(:coupons)).to eq([coupon[4], coupon[5]])
    end 

    it "sets @coupon_codes" do
      coupon1 = Fabricate( :coupon, code: 'now', end_date: Time.now + 1.hour )
      coupon1.categories << cat1
      get :show, id: cat1.id
      expect(assigns(:coupon_codes)).to eq([coupon1])
    end

    it "sets @coupon_offers" do
      coupon1 = Fabricate( :coupon, code: nil, end_date: Time.now + 1.hour )
      coupon1.categories << cat1
      get :show, id: cat1.id
      expect(assigns(:coupon_offers)).to eq([coupon1])
    end
  end
end