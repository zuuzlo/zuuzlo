class CouponsController < ApplicationController
  include CouponCodesOffers
  def index
  end

  def search
    @coupons = Coupon.search_by_title(params[:search_term])
    @term = params[:search_term]

    @coupon_codes = coupon_codes(@coupons)
    @coupon_offers = coupon_offers(@coupons)
  end
end
