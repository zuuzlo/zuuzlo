require 'spec_helper'

class FakesController < ApplicationController
  include LoadSeo
end

describe FakesController do
  let(:cat1) { Fabricate(:category, name: "CatName") }
  before do 
    store1 = Fabricate(:store, commission: 10)
    coupon = Array.new
    
    (1..7).each do |i|
      coupon[i] = Fabricate(:coupon,store_id: store1.id, title: "coupon#{i}", code: ( i%2 == 0) ? "COUP#{i}" : nil, start_date: Time.now - i.day, end_date: Time.now + i.day )
      cat1.coupons << coupon[i]
    end
  end
  context "no user" do
    describe "#seo_description" do
      it "returns meta_description" do
        expect(subject.seo_description(Coupon.all, cat1)).to be_a(String)
      end
      it "limit size of meta_description to less than 150 charaters" do
        expect(subject.seo_description(Coupon.all, cat1).length).to be < 160
      end
    end

    describe "#seo_keywords" do
      it "returns keywords" do
        expect(subject.seo_keywords(Coupon.all, cat1)).to be_a(String)
      end
    end
  end

  context "with user" do
    before { set_current_user }
    describe "#seo_description" do
      it "returns meta_description" do
        expect(subject.seo_description(Coupon.all, cat1)).to eq("checking")
      end
    end

    describe "#find_keywords" do
      it "returns keywords" do
        expect(subject.seo_keywords(Coupon.all, cat1)).to eq("kohls, kohls coupons")
      end
    end
  end
end