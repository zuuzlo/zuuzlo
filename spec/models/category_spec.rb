require_relative '../spec_helper'

describe Category do
  it { should have_and_belong_to_many(:coupons) }
  it { should validate_presence_of(:name) }

  let(:computers) {Fabricate(:category, name: "computers") }
  let(:pets) { Fabricate(:category, name: "pets") }
  
  describe "with_coupons" do
    it "should return all categories with coupons end_date after time now with name in alphabit order" do
      coupon = Array.new
      (1..3).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now + i.hour )
        coupon[i].categories << computers
        coupon[i].categories << pets
      end 
      expect(Category.with_coupons).to eq([computers, pets])
    end

    it "should return only category with coupons not out of date" do
      coupon = Array.new
      (1..3).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now - i.hour )
        coupon[i].categories << computers
      end

      (4..5).each do |i|
        coupon[i] = Fabricate(:coupon, title: "coupon#{i}", end_date: Time.now + i.hour )
        coupon[i].categories << pets
      end  
      expect(Category.with_coupons).to eq([pets])
    end

  end
end