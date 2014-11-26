require 'spec_helper'

class FakesController < ApplicationController
  include LatestCoupon
end

describe FakesController do
  let!(:cat) { Fabricate(:category) }
  let!(:type) { Fabricate(:ctype) }
  (1..3).each do |i|
    let!("coupon#{i}".to_sym) { Fabricate(:coupon, title: "coupon#{i}", code: "CODE#{i}", created_at:  Time.now - i.hour, end_date: Time.now + i.hour, start_date: Time.now - 12.hour ) }
  end
  before do
    (1..3).each do |i|
      eval("coupon#{i}").categories << cat
      eval("coupon#{i}").ctypes << type
    end
  end

  it "returns latest coupon for category" do
    expect(subject.latest_coupon_date(cat)).to eq(I18n.l(coupon1.created_at, :format => :w3c))
  end

  it "returns latest coupon for ype" do
    expect(subject.latest_coupon_date(type)).to eq(I18n.l(coupon1.created_at, :format => :w3c))
  end
end