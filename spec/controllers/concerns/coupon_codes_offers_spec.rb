require 'spec_helper'

class FakesController < ApplicationController
  include CouponCodesOffers
end

describe FakesController do
  (1..3).each do |i|
    let!("coupon#{i}".to_sym) { Fabricate(:coupon, title: "coupon#{i}", code: "CODE#{i}", end_date: Time.now + i.hour, start_date: Time.now - 12.hour ) }
  end

  (4..5).each do |i|
    let!("coupon#{i}".to_sym) { Fabricate(:coupon, title: "coupon#{i}", code: nil, end_date: Time.now + i.day, start_date: Time.now - 12.hour ) }
  end 

  describe "#coupon_codes" do
    it "should return 3 coupon codes" do
      expect(subject.coupon_codes(Coupon.all)).to eq(3)
    end
  end

  describe "#coupon_offers" do
    it "should return 2 coupon codes" do
      expect(subject.coupon_offers(Coupon.all)).to eq(2)
    end
  end 
end