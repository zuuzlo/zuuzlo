require 'spec_helper'

describe CategoriesController do

  describe "GET show" do
    let!(:cat1) { Fabricate(:category) }

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

    it "sets number of codes_count" do
      coupon1 = Fabricate( :coupon, code: 'now', end_date: Time.now + 1.hour )
      coupon1.categories << cat1
      get :show, id: cat1.id
      expect(assigns(:codes_count)).to eq(1)
    end

    it "sets number of offers_count" do
      coupon1 = Fabricate( :coupon, code: nil, end_date: Time.now + 1.hour )
      coupon1.categories << cat1
      get :show, id: cat1.id
      expect(assigns(:offers_count)).to eq(1)
    end
  end
end